//
//  MaaSDocDetectionPreviewViewController.h
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 10/1/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaaSDocDetectionAVCamPreviewView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MaaSDocAction) {
    MaaSDocActionDetectEdges = 0,
    MaaSDocActionDetectContours = 1,
    MaaSDocActionDetectHoughLines = 2,
    MaaSDocActionDetectIntersections = 3,
    MaaSDocActionDetectDocContours = 4,
    MaaSDocActionDetectDocCapture = 5
};

@class MaaSDocDetectionPreviewViewController;

@protocol MaaSDocDetectionPreviewViewControllerDelegate <NSObject>

- (void)docDetectionPreviewViewControllerDidLoad:(MaaSDocDetectionPreviewViewController *)controller;
- (void)docDetectionPreviewViewControllerDidCancel:(MaaSDocDetectionPreviewViewController *)controller;
- (void)docDetectionPreviewViewController:(MaaSDocDetectionPreviewViewController *)controller action:(MaaSDocAction)action info:( nullable id)info;

@end

@interface MaaSDocDetectionPreviewViewController : UIViewController

+ (instancetype)loadPreviewViewController;

@property (nonatomic, weak) id<MaaSDocDetectionPreviewViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet MaaSDocDetectionAVCamPreviewView *previewView;

@end

NS_ASSUME_NONNULL_END
