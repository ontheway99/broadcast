//
//  ViewController.h
//  broadcast
//
//  Created by Mark on 14/12/8.
//  Copyright (c) 2014年 cv. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import <Availability.h>

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "ConfigViewController.h"

@interface ViewController : UIViewController<PassConfigValueDelegate>
{
 //   CvVideoCamera* videoCamera;
    bool isCapturing;
    bool isPushing;
    NSString* strRTMPURLStored;
}

//@property (nonatomic, retain) CvVideoCamera* videoCamera;
//@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
- (IBAction)OnStartButtonPressed:(id)sender;
- (void) startPreview;
@end

