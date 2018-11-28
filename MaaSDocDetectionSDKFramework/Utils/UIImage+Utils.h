//
//  UIImage+Utils.h
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 10/5/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Utils)

+(UIImage*) imageWithImageBuffer:(CVImageBufferRef) imgBuffer;
+(UIImage*) imageWithImageBuffer:(CVImageBufferRef) imgBuffer inRect:(CGRect)rect;
+(UIImage*) fixedOrientation:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
