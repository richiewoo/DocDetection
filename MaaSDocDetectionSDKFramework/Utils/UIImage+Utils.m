//
//  Utils.m
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 10/5/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation UIImage (Utils)

+(UIImage*) imageWithImageBuffer:(CVImageBufferRef) imgBuffer
{
    CVPixelBufferLockBaseAddress(imgBuffer,0);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imgBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    
    size_t width =  CVPixelBufferGetWidth(imgBuffer);
    size_t height = CVPixelBufferGetHeight(imgBuffer);
    
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 width,
                                                 height)];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage scale:[UIScreen mainScreen].scale orientation: [UIImage imageOrientationFromDeviceOrientation]];
    CGImageRelease(videoImage);
    
    CVPixelBufferUnlockBaseAddress(imgBuffer,0);
    
    return image;
}

+(UIImage*) imageWithImageBuffer:(CVImageBufferRef) imgBuffer inRect:(CGRect)rect
{
    CVPixelBufferLockBaseAddress(imgBuffer,0);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imgBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:rect];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage scale:[UIScreen mainScreen].scale orientation:[UIImage imageOrientationFromDeviceOrientation]];
    CGImageRelease(videoImage);
    
    CVPixelBufferUnlockBaseAddress(imgBuffer,0);
    
    return image;
}

+(UIImage*) fixedOrientation:(UIImage*) image {
    
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default: break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            // CORRECTION: Need to assign to transform here
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            // CORRECTION: Need to assign to transform here
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default: break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(nil, image.size.width, image.size.height, CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), kCGImageAlphaPremultipliedLast);
    
    CGContextConcatCTM(ctx, transform);
    
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
            break;
    }
    
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    
    return [UIImage imageWithCGImage:cgImage];
}

+(UIImageOrientation)imageOrientationFromDeviceOrientation
{
    UIDeviceOrientation curDeviceOrientation = [UIDevice currentDevice].orientation;
    
    CGImagePropertyOrientation exifOrientation = UIImageOrientationUp;
    
    switch (curDeviceOrientation)
    {
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            exifOrientation = UIImageOrientationRight; break;
            
        case UIDeviceOrientationLandscapeRight:     // Device oriented horizontally, home button on the left
            exifOrientation = UIImageOrientationRight; break;
            
        case UIDeviceOrientationPortraitUpsideDown: // Device oriented vertically, home button on the top
            exifOrientation = UIImageOrientationRight; break;
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortrait:           // Device oriented vertically, home button on the bottom
            exifOrientation = UIImageOrientationRight; break;
        default:
            exifOrientation = UIImageOrientationRight; break;
            break;
    };
    
    return exifOrientation;
}

@end
