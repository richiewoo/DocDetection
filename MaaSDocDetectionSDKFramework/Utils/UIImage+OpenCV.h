//
//  UIImage+OpenCV.h
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/17/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (OpenCV)

+(UIImage*) imageWithMat:(const cv::Mat&) image andImageOrientation: (UIImageOrientation) orientation;
+(UIImage*) imageWithMat:(const cv::Mat&) image andDeviceOrientation: (UIDeviceOrientation) orientation;

+(CGImagePropertyOrientation) exifOrientationFromDeviceOrientation;


-(cv::Mat) toMat;


@end
