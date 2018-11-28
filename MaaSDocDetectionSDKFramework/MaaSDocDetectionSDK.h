//
//  MaaSDocDetectionSDK.h
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/19/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MaaSDocDetectionSDKDelegate <NSObject>

- (void)docDetectionSDKDidDetectImage:(UIImage *)detectedDocImage;

@end

@interface MaaSDocDetectionSDK : NSObject

-(instancetype)initWithViewController:(UIViewController*)containerViewController delegate:(id<MaaSDocDetectionSDKDelegate>)delegate;

-(void)startScan;

@end
