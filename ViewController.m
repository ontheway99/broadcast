///
//  ViewController.m
//  broadcast
//
//  Created by Mark on 14/12/8.
//  Copyright (c) 2014年 cv. All rights reserved.
//

#import "ViewController.h"
#import "RtmpClient.h"
#import "CameraServer.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize cameraView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*self.videoCamera = [[CvVideoCamera alloc]
                        initWithParentView:imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    
    [videoCamera start];
    isCapturing = TRUE;*/
    [self startPreview];
    
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is not the most beautiful animation...
    AVCaptureVideoPreviewLayer* preview = [[CameraServer server] getPreviewLayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
}

- (void) startPreview
{
    AVCaptureVideoPreviewLayer* preview = [[CameraServer server] getPreviewLayer];
    [preview removeFromSuperlayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    
    [self.cameraView.layer addSublayer:preview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)PassConfigValues:(NSString *)values
{
    strRTMPURLStored = [[NSString alloc] initWithFormat:@"%@",values];
    NSLog(@"Value:::%@",values);
    NSLog(@"RTMP URL:::%@",strRTMPURLStored);
}

- (IBAction)OnStartButtonPressed:(id)sender {

    if( !isPushing )
    {
        RTMPClientInit();
        if( RTMPClientConnect((char*)[strRTMPURLStored UTF8String]) == true )
        {
            isPushing = true;
        }
        else
        {
            RTMPClientExit();
        }
    }
    else
    {
        RTMPClientClose();
        RTMPClientExit();
        isPushing = false;
    }
}

@end
