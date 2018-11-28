//
//  MaaSImageProcessFacade.h
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaasImageProcessBase.hpp"

@interface MaaSImageProcessFacade : NSObject

//@property (getter = getIsReferenceFrameRequired, readonly) bool isReferenceFrameRequired;

//- (id) initWithSample:(MaaSImageProcessBase*) sample;
//
//- (NSString *) title;
//- (NSString *) description;

//- (bool) processFrame:(const cv::Mat&) inputFrame into:(cv::Mat&) outputFrame;

- (UIImage*) processFrameForEdgeImg:(CVImageBufferRef) source;
- (UIImage*) processFrameForContourImg:(CVImageBufferRef) source;
- (UIImage*) processFrameForHoughLinesImg:(CVImageBufferRef) source;
- (UIImage*) processFrameForIntesectionImg:(CVImageBufferRef) source;
- (UIImage*) processFrameForFinalDocContourImg:(CVImageBufferRef) source;


- (NSArray*) processFrame:(CVImageBufferRef) source;

- (UIImage*) cropImage;
//
//- (OptionsMap) getOptions;
//
//- (void) setReferenceFrame:(cv::Mat&) referenceFrame;
//- (void) resetReferenceFrame;

@end
