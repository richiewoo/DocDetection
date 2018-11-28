//
//  MaaSDocDetectionSDK.m
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/19/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import "MaaSDocDetectionSDK.h"
#import "MaaSDocDetectionLiveCapture.h"
#import "MaaSImageProcessFacade.h"
#import "UIImage+OpenCV.h"

@interface MaaSDocDetectionSDK () <MaaSDocDetectionPreviewViewControllerDelegate>

@property (nonatomic) MaaSDocDetectionLiveCapture *liveCapture;
@property (nonatomic) MaaSImageProcessFacade *imgProcessHandle;
@property (nonatomic) dispatch_queue_t imgProcessQueue;
@property (nonatomic) NSLock* lock;
@property (nonatomic) CVImageBufferRef latestPixelBuffer;
@property (nonatomic) CVImageBufferRef currentPixelBuffer;

@property (nonatomic, assign) BOOL isReadyProcess;

@property (nonatomic, weak) id<MaaSDocDetectionSDKDelegate> delegate;
@property (nonatomic) UIViewController* containerViewController;

@property (nonatomic) MaaSDocDetectionPreviewViewController* previewViewController;

@property (nonatomic, assign) MaaSDocAction action;

@end

@implementation MaaSDocDetectionSDK

-(instancetype)initWithViewController:(UIViewController*)containerViewController delegate:(id<MaaSDocDetectionSDKDelegate>)delegate
{
    if (self = [super init]) {
        
        _containerViewController = containerViewController;
        _delegate = delegate;
        
        _imgProcessHandle = [[MaaSImageProcessFacade alloc] init];
        
        _imgProcessQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
        _lock = [[NSLock alloc] init];
        _isReadyProcess = YES;
        
    }
    
    return self;
}

- (void)docDetectionPreviewViewControllerDidLoad:(MaaSDocDetectionPreviewViewController *)controller
{
    __typeof__(self) __weak wself = self;
    _liveCapture = [[MaaSDocDetectionLiveCapture alloc] initWithPreviewViewViewController:_previewViewController withResultBlock:^(MaaSDocDetectionAVCamState statue, id data) {
        switch (statue) {
            case AVCamStateInitialized:
                 [wself.liveCapture startScanning];
                break;
            case AVCamStateScanning:
                if (data != nil) {
                    CVImageBufferRef pixelBuffer = (__bridge CVImageBufferRef)data;
                    [self processBuffer:pixelBuffer];
                }
                break;
            case AVCamStateStopped:
                wself.liveCapture = nil;
                wself.previewViewController = nil;
                
            default:
                break;
        }
    }];
}

- (void)docDetectionPreviewViewControllerDidCancel:(MaaSDocDetectionPreviewViewController *)controller
{
    
}

- (void)docDetectionPreviewViewController:(MaaSDocDetectionPreviewViewController *)controller action:(MaaSDocAction)action info:(id)info
{
    if (action == MaaSDocActionDetectDocCapture) {
        [self.liveCapture stopScanning];
        
        UIImage* image = [_imgProcessHandle cropImage];
        
        if (self.delegate) {
            [self.delegate docDetectionSDKDidDetectImage:image];
        }
        [_containerViewController.navigationController popViewControllerAnimated:YES];
    }
    else{
            _action = action;
    }
}

-(void)startScan
{
    self.action = MaaSDocActionDetectEdges;
    self.previewViewController =[MaaSDocDetectionPreviewViewController loadPreviewViewController];
    self.previewViewController.delegate = self;

    _previewViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [_containerViewController presentViewController:_previewViewController animated:YES completion:^{
        
    }];
}

-(void)processBuffer:(CVImageBufferRef)pixelBuffer
{
    [self.lock lock];
    self.latestPixelBuffer = pixelBuffer;
    
    if (self.isReadyProcess) {
        
        self.isReadyProcess = NO;
        self.currentPixelBuffer = self.latestPixelBuffer;
        
        CFRetain(self.currentPixelBuffer);

        __typeof__(self) __weak wself = self;
        dispatch_async(self.imgProcessQueue, ^{
            
            NSLog(@"Start process frame");
            
            UIImage* img = nil;
            NSArray *pts = nil;
            if (wself.action == MaaSDocActionDetectEdges) {
                img = [wself.imgProcessHandle processFrameForEdgeImg:wself.currentPixelBuffer];
            }
            if (wself.action == MaaSDocActionDetectContours) {
                img = [wself.imgProcessHandle processFrameForContourImg:wself.currentPixelBuffer];
            }
            if (wself.action == MaaSDocActionDetectHoughLines) {
                img = [wself.imgProcessHandle processFrameForHoughLinesImg:wself.currentPixelBuffer];
            }
            if (wself.action == MaaSDocActionDetectIntersections) {
                img = [wself.imgProcessHandle processFrameForIntesectionImg:wself.currentPixelBuffer];
            }
            if (wself.action == MaaSDocActionDetectDocContours) {
                pts = [wself.imgProcessHandle processFrame:wself.currentPixelBuffer];
                
                if (pts) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [wself.liveCapture drawSampleImg:nil];
                        [wself.liveCapture drawDocContours:pts];
                    });
                }
            }
            else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [wself.liveCapture drawSampleImg:img];
                });
            }
            
            [self.lock lock];
            CFRelease(wself.currentPixelBuffer);
            wself.currentPixelBuffer = nil;
            wself.isReadyProcess = YES;
            [self.lock unlock];
        });
    }
    [self.lock unlock];
    
}

@end
