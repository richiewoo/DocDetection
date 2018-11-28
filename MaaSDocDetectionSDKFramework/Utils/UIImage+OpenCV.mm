//
//  UIImage+OpenCV.m
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/17/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import "UIImage+OpenCV.h"

@implementation UIImage (OpenCV)



+(UIImage*) imageWithMat:(const cv::Mat&) image andDeviceOrientation: (UIDeviceOrientation) orientation
{
    CGImagePropertyOrientation exifOrientation = UIImageOrientationUp;
    
    switch (orientation)
    {
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            exifOrientation = kCGImagePropertyOrientationUpMirrored; break;
            
        case UIDeviceOrientationLandscapeRight:     // Device oriented horizontally, home button on the left
            exifOrientation = kCGImagePropertyOrientationDown; break;
            
        case UIDeviceOrientationPortraitUpsideDown: // Device oriented vertically, home button on the top
            exifOrientation = kCGImagePropertyOrientationLeft; break;
            
        case UIDeviceOrientationPortrait:           // Device oriented vertically, home button on the bottom
            exifOrientation = kCGImagePropertyOrientationUp; break;
        default:
            exifOrientation = kCGImagePropertyOrientationUp; break;
            break;
    };
    
    return [UIImage imageWithMat:image andImageOrientation:exifOrientation];
}

+(UIImage*) imageWithMat:(const cv::Mat&) image andImageOrientation: (UIImageOrientation) orientation;
{
    cv::Mat rgbaView;
    
    if (image.channels() == 3)
    {
        cv::cvtColor(image, rgbaView, cv::COLOR_BGR2RGBA);
    }
    else if (image.channels() == 4)
    {
        cv::cvtColor(image, rgbaView, cv::COLOR_BGRA2RGBA);
    }
    else if (image.channels() == 1)
    {
        cv::cvtColor(image, rgbaView, cv::COLOR_GRAY2RGBA);
    }
    
    NSData *data = [NSData dataWithBytes:rgbaView.data length:rgbaView.elemSize() * rgbaView.total()];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGBitmapInfo bmInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(rgbaView.cols,                              //width
                                        rgbaView.rows,                              //height
                                        8,                                          //bits per component
                                        8 * rgbaView.elemSize(),                    //bits per pixel
                                        rgbaView.step.p[0],                         //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        bmInfo,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:orientation];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+(CGImagePropertyOrientation)exifOrientationFromDeviceOrientation
{
    UIDeviceOrientation curDeviceOrientation = [UIDevice currentDevice].orientation;
    
    CGImagePropertyOrientation exifOrientation = UIImageOrientationUp;
    
    switch (curDeviceOrientation)
    {
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            exifOrientation = kCGImagePropertyOrientationUpMirrored; break;
            
        case UIDeviceOrientationLandscapeRight:     // Device oriented horizontally, home button on the left
            exifOrientation = kCGImagePropertyOrientationDown; break;
            
        case UIDeviceOrientationPortraitUpsideDown: // Device oriented vertically, home button on the top
            exifOrientation = kCGImagePropertyOrientationLeft; break;
            
        case UIDeviceOrientationPortrait:           // Device oriented vertically, home button on the bottom
            exifOrientation = kCGImagePropertyOrientationUp; break;
        default:
            exifOrientation = kCGImagePropertyOrientationUp; break;
            break;
    };
    
    return exifOrientation;
}

-(cv::Mat) toMat
{
    CGImageRef imageRef = self.CGImage;
    
    const int srcWidth        = (int)CGImageGetWidth(imageRef);
    const int srcHeight       = (int)CGImageGetHeight(imageRef);
    
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef rawData = CGDataProviderCopyData(dataProvider);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    cv::Mat rgbaContainer(srcHeight, srcWidth, CV_8UC4);
    CGContextRef context = CGBitmapContextCreate(rgbaContainer.data,
                                                 srcWidth,
                                                 srcHeight,
                                                 8,
                                                 4 * srcWidth,
                                                 colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, srcWidth, srcHeight), imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    CFRelease(rawData);
    
    cv::Mat t;
    cv::cvtColor(rgbaContainer, t, cv::COLOR_RGBA2BGRA);
    
    return t;
}


@end
