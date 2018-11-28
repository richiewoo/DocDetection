//
//  MaaSDocDetectionAVCamPreviewView.m
//  LiveCapture
//
//  Created by Xinbo Wu on 9/20/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import "MaaSDocDetectionAVCamPreviewView.h"

@implementation MaaSDocDetectionAVCamPreviewView

-(instancetype)init{
    if (self = [super init]) {
        
        [self initSublayers];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initSublayers];
    }
    
    return self;
}

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

-(void)initSublayers
{
//    _detectedDocImgView = [[UIImageView alloc] init];
//    [self addSubview:_detectedDocImgView];
//    _detectedDocImgView.contentMode = UIViewContentModeCenter;
    
    _detectionOverlay = [CAShapeLayer layer];
    [self.layer addSublayer:_detectionOverlay];
    
    _detectionOverlay.name = @"DocDetectionOverlay";
    _detectionOverlay.contentsGravity = kCAGravityResizeAspectFill;
    [_detectionOverlay setStrokeColor:[[UIColor greenColor] CGColor]];
    [_detectionOverlay setFillColor:[[UIColor clearColor] CGColor]];
    [_detectionOverlay setLineWidth:2.0];
    
    self.layer.backgroundColor = [UIColor grayColor].CGColor;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.videoPreviewLayer.session = session;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //_detectedDocImgView.frame = self.bounds;
    _detectionOverlay.frame = self.bounds;
}
@end
