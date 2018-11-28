//
//  MaaSDocDetectionPreviewViewController.m
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 10/1/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import "MaaSDocDetectionPreviewViewController.h"

@interface MaaSDocDetectionPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *samplePickerView;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;

@property (strong, nonatomic) void (^loadBlock)(BOOL res);

@end

@implementation MaaSDocDetectionPreviewViewController


-(NSDictionary*)getSamples{
    return @{
             @(MaaSDocActionDetectEdges) : @"Edges",
             @(MaaSDocActionDetectContours) : @"Contours",
             @(MaaSDocActionDetectHoughLines) : @"HoughLines",
             @(MaaSDocActionDetectIntersections) : @"Intersections",
             @(MaaSDocActionDetectDocContours) : @"DocContour"
             };
}

+ (instancetype)loadPreviewViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([MaaSDocDetectionPreviewViewController class])
                                          bundle:[NSBundle bundleForClass:[MaaSDocDetectionPreviewViewController class]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.delegate) {
        [self.delegate docDetectionPreviewViewControllerDidLoad:self];
    }
    self.captureButton.hidden = YES;
    _samplePickerView.hidden = NO;
}

-(void)dealloc
{
    
}

- (IBAction)captureDoc:(id)sender {
    
    if (self.delegate) {
        [self.delegate docDetectionPreviewViewController:self action:(MaaSDocAction)MaaSDocActionDetectDocCapture info:nil];
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        
        [self.delegate docDetectionPreviewViewControllerDidCancel:self];
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self getSamples].count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [[self getSamples] objectForKey:@(row)];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.delegate) {
        MaaSDocAction action = (MaaSDocAction)row;
        if (action == MaaSDocActionDetectDocContours) {
            self.captureButton.hidden = NO;
        }
        else{
            self.captureButton.hidden = YES;
        }
        [self.delegate docDetectionPreviewViewController:self action:action info:nil];
    }
}

@end
