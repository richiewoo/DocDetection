//
//  MaaSDocDetectionAVCamPreviewView.h
//  LiveCapture
//
//  Created by Xinbo Wu on 9/20/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MaaSDocDetectionAVCamPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) CAShapeLayer* detectionOverlay;

@property (nonatomic) AVCaptureSession *session;

@end
