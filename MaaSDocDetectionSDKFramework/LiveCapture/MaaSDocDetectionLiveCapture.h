//
//  MaaSDocDetectionLiveCapture.h
//  LiveCapture
//
//  Created by Xinbo Wu on 9/20/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import "MaaSDocDetectionAVCamPreviewView.h"
#import "MaaSDocDetectionPreviewViewController.h"

typedef NS_ENUM( NSInteger, MaaSDocDetectionAVCamState ) {
    AVCamStateInitializing,
    AVCamStateInitialized,
    AVCamStateScanning,
    AVCamStateStopped,
    AVCamStateCameraNotAuthorized,
    AVCamStateSessionConfigurationFailed
};

typedef void (^resultBlock)(MaaSDocDetectionAVCamState statue, id data);

@interface MaaSDocDetectionLiveCapture : NSObject

-(instancetype)initWithPreviewView:(MaaSDocDetectionAVCamPreviewView*)previewView withResultBlock:(resultBlock)block;
-(instancetype)initWithPreviewViewViewController:(MaaSDocDetectionPreviewViewController*)previewViewController withResultBlock:(resultBlock)block;

/**
 *  Returns whether any camera exists in this device.
 *  Be aware that this returns NO if camera access is restricted.
 *
 *  @return YES if the device has a camera and authorization state is not AVAuthorizationStatusRestricted
 */
+ (BOOL)cameraIsPresent;
/**
 *  Returns whether scanning is prohibited by the user of the device.
 *
 *  @return YES if the user has prohibited access to (or is prohibited from accessing) the camera.
 */
+ (BOOL)scanningIsProhibited;

-(void) drawSampleImg:(UIImage*)detectedImg;
-(void) drawDocContours:(NSArray<NSValue*>*) contours;

-(void) startScanning;
-(void) stopScanning;
-(void) teardownAVCaptureSession;

@end
