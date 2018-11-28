//
//  ViewController.m
//  DocScannerExample
//
//  Created by Xinbo Wu on 9/20/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import "ViewController.h"
@import MaaSDocDetectionSDKFramework;

@interface ViewController () <MaaSDocDetectionSDKDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *detectedDocImgView;
@property(nonatomic) MaaSDocDetectionSDK* docDectectionSDK;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.docImgView.contentMode = UIViewContentModeScaleAspectFit;
    _docDectectionSDK = [[MaaSDocDetectionSDK alloc] initWithViewController:self delegate:self];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//       [_docDectectionSDK startScan];
//    });
    
}
- (void)docDetectionSDKDidDetectImage:(UIImage *)detectedDocImage
{
    self.docImgView.image = detectedDocImage;
}

- (IBAction)startScan:(id)sender {
    
    [_docDectectionSDK startScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
