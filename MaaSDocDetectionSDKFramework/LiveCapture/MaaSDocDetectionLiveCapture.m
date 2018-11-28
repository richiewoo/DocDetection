//
//  MaaSDocDetectionLiveCapture.m
//  LiveCapture
//
//  Created by Xinbo Wu on 9/20/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import "MaaSDocDetectionLiveCapture.h"
#import "UIImage+Utils.h"

@interface MaaSDocDetectionLiveCapture () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CGSize bufferSize;
}

/*!
 @property privateSessionQueue
 @abstract
 Starting or stopping the capture session should only be done on this queue.
 */
@property (strong) dispatch_queue_t privateSessionQueue;

@property (nonatomic) MaaSDocDetectionAVCamState sessionResult;

/*!
 @property session
 @abstract
 The capture session used for scanning barcodes.
 */
@property (nonatomic, strong) AVCaptureSession *session;
/*!
 @property captureDevice
 @abstract
 Represents the physical device that is used for scanning barcodes.
 */
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
/*!
 @property currentCaptureDeviceInput
 @abstract
 The current capture device input for capturing video. This is used
 to reset the camera to its initial properties when scanning stops.
 */
@property (nonatomic, strong) AVCaptureDeviceInput *currentCaptureDeviceInput;
/*
 @property currentCaptureOutput
 @abstract
 The capture device output for capturing video.
 */
@property (nonatomic, strong) AVCaptureVideoDataOutput *currentCaptureOutput;

/*!
 @property capturePreviewView
 @abstract
 The view used to preview the camera input.
 
 @discussion
 The AVCaptureVideoPreviewLayer is added to this view to preview the
 camera input when scanning starts. When scanning stops, the layer is
 removed.
 */
@property (strong, nonatomic) MaaSDocDetectionAVCamPreviewView* capturePreviewView;

@property (strong, nonatomic) resultBlock resultCallback;

@end

@implementation MaaSDocDetectionLiveCapture

-(instancetype)initWithPreviewView:(MaaSDocDetectionAVCamPreviewView*)previewView withResultBlock:(resultBlock)block
{
    if (self = [super init]) {
        _resultCallback = block;
        if (previewView) {
            [self setupSessionQueue];
            [self setupSession];
            [self initViews:previewView];
        }
        else{
            return nil;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    return self;
}

-(instancetype)initWithPreviewViewViewController:(MaaSDocDetectionPreviewViewController*)previewViewController withResultBlock:(resultBlock)block;
{
    return [self initWithPreviewView:previewViewController.previewView withResultBlock:block];
}

- (void)setupSessionQueue {
    NSAssert(self.privateSessionQueue == NULL, @"Queue should only be set up once");
    
    if (self.privateSessionQueue) {
        return;
    }
    
    self.privateSessionQueue = dispatch_queue_create("com.fiberlink.MaaSDocDetectionSDKFramework.captureSession", DISPATCH_QUEUE_SERIAL);
}

-(void)dealloc
{
    
}

- (MaaSDocDetectionAVCamPreviewView *)avCamPreviewView
{
    return self.capturePreviewView;
}

+ (BOOL)cameraIsPresent {
    // capture device is nil if status is AVAuthorizationStatusRestricted
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] != nil;
}

+ (BOOL)scanningIsProhibited {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
}

+ (void)requestCameraPermissionWithSuccess:(void (^)(BOOL success))successBlock {
    if (![self cameraIsPresent]) {
        successBlock(NO);
        return;
    }
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            successBlock(YES);
            break;
            
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            successBlock(NO);
            break;
            
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             successBlock(granted);
                                         });
                                         
                                     }];
            break;
    }
}

-(void) drawSampleImg:(UIImage*)detectedImg
{
    if (self.capturePreviewView.detectionOverlay) {
        self.capturePreviewView.detectionOverlay.path = nil;
        self.capturePreviewView.detectionOverlay.contents = (__bridge id _Nullable)([UIImage fixedOrientation:detectedImg].CGImage);
    }
}

-(void) drawDocContours:(NSArray<NSValue*>*) contours
{
    self.capturePreviewView.detectionOverlay.contents = nil;
    
    if (contours && contours.count > 0) {
        
        // Draw contours.
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        
        NSValue* ptValue = contours[0];
        CGPoint pt = ptValue.CGPointValue;

        //Convert the point to layer coordinate
        CGPoint convertedpt = [self.capturePreviewView.videoPreviewLayer pointForCaptureDevicePointOfInterest:pt];
        
        [aPath moveToPoint: convertedpt];
        
        NSLog(@"converted Pt 0: x = %.5f, y = %.5f, Pt: x = %.5f, y = %.5f", convertedpt.x, convertedpt.y, pt.x, pt.y);
       
        for (int i = 1; i < contours.count; i++) {
            ptValue = contours[i];
            pt = ptValue.CGPointValue;
            
            //Convert the point to layer coordinate
            convertedpt = [self.capturePreviewView.videoPreviewLayer pointForCaptureDevicePointOfInterest:pt];
            
            [aPath addLineToPoint: convertedpt];
            
            NSLog(@"converted Pt %d: x = %.5f, y = %.5f, Pt: x = %.5f, y = %.5f", i, convertedpt.x, convertedpt.y, pt.x, pt.y);
        }
        [aPath closePath];
        [self.capturePreviewView.detectionOverlay setPath:[aPath CGPath]];
    }
}

-(void)initViews:(MaaSDocDetectionAVCamPreviewView*)previewView
{    
    _capturePreviewView = previewView;
    _capturePreviewView.session = _session;
    _capturePreviewView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

-(void)setupSession;
{
    _sessionResult = AVCamStateInitializing;
    
    _session = [[AVCaptureSession alloc] init];
    
    if (@available(iOS 10.2, *)) {
        _captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    } else {
        // Fallback on earlier versions
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    if ( ! _captureDevice ) {
        // If the back dual camera is not available, default to the back wide angle camera.
        _captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    
    _currentCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice: _captureDevice error:nil];
    
    _currentCaptureOutput = [[AVCaptureVideoDataOutput alloc]init];
    
    /*
     Check video authorization status. Video access is required
     */
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             */
            dispatch_suspend( self.privateSessionQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.sessionResult = AVCamStateCameraNotAuthorized;
                }
                dispatch_resume( self.privateSessionQueue );
                
                dispatch_async( self.privateSessionQueue, ^{
                    self.resultCallback(self.sessionResult, nil);
                } );
            }];
            break;
        }
        default:
        {
            // The user has previously denied access.
            self.sessionResult = AVCamStateCameraNotAuthorized;
            dispatch_async( self.privateSessionQueue, ^{
                self.resultCallback(self.sessionResult, nil);
            } );
            break;
        }
    }
    
    /*
     Setup the capture session.
     In general it is not safe to mutate an AVCaptureSession or any of its
     inputs, outputs, or connections from multiple threads at the same time.
     
     Why not do all of this on the main queue?
     Because -[AVCaptureSession startRunning] is a blocking call which can
     take a long time. We dispatch session setup to the sessionQueue so
     that the main queue isn't blocked, which keeps the UI responsive.
     */
    dispatch_async( self.privateSessionQueue, ^{
        [self configureSession];
    } );
}

// Call this on the session queue.
- (void)configureSession
{
    NSError *error = nil;
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    if ([self.session canAddInput:_currentCaptureDeviceInput])
    {
        [self.session addInput:_currentCaptureDeviceInput];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.capturePreviewView.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        } );
    }
    else
    {
        self.sessionResult = AVCamStateSessionConfigurationFailed;
        [self.session commitConfiguration];
        self.resultCallback(self.sessionResult, nil);
        return;
    }
    
    if ([self.session canAddOutput:_currentCaptureOutput])
    {
        [self.session addOutput:_currentCaptureOutput];

        self.currentCaptureOutput.alwaysDiscardsLateVideoFrames = true;
        self.currentCaptureOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]};

        [self.currentCaptureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    }
    else
    {
        self.sessionResult = AVCamStateSessionConfigurationFailed;
        [self.session commitConfiguration];
        self.resultCallback(self.sessionResult, nil);
        return;
    }
    
    AVCaptureConnection *captureConnection = [_currentCaptureOutput connectionWithMediaType:(AVMediaTypeVideo)];
    [captureConnection setEnabled: YES];
    if ( captureConnection.isVideoStabilizationSupported ) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    
    [_captureDevice lockForConfiguration:&error];
    if (error == nil) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(_captureDevice.activeFormat.formatDescription);
        bufferSize.width = dimension.width;
        bufferSize.height = dimension.height;
        [_captureDevice unlockForConfiguration];
    }
    
    [self.session commitConfiguration];
    
    self.sessionResult = AVCamStateInitialized;
    self.resultCallback(self.sessionResult, nil);
}

- (void)rotated:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        self.capturePreviewView.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}
-(void)startScanning
{
    if (self.sessionResult == AVCamStateInitialized
        ||self.sessionResult == AVCamStateStopped) {
        __typeof__(self) __weak wself = self;
        dispatch_async( self.privateSessionQueue, ^{
            [wself.session startRunning];
            wself.sessionResult = AVCamStateScanning;
            wself.resultCallback(wself.sessionResult, nil);
        } );
    }
}

-(void)stopScanning
{
    if (self.sessionResult == AVCamStateScanning) {
        __typeof__(self) __weak wself = self;
        dispatch_async( self.privateSessionQueue, ^{
            [wself.session stopRunning];
            wself.sessionResult = AVCamStateStopped;
            wself.resultCallback(wself.sessionResult, nil);
        } );
    }
}

// Clean up capture setup
-(void) teardownAVCaptureSession {
    [self stopScanning];
    [self.capturePreviewView removeFromSuperview];
    self.capturePreviewView = nil;
    // remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (CMSampleBufferGetNumSamples(sampleBuffer) > 0
        &&CMSampleBufferIsValid(sampleBuffer)) {
        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (self.resultCallback) {
            self.resultCallback(self.sessionResult, (__bridge id)(pixelBuffer));
        }
    }
}

@end
