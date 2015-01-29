//
//  CameraServer.m
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "CameraServer.h"
#import "AVEncoder.h"
#import "RtmpClient.h"


static CameraServer* theServer;

@interface CameraServer  () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession* _session;
    AVCaptureVideoPreviewLayer* _preview;
    AVCaptureVideoDataOutput* _output;
    dispatch_queue_t _captureQueue;
    
    AVEncoder* _encoder;
    double _basePTS;
    
//    RTSPServer* _rtsp;
}
@end


@implementation CameraServer

+ (void) initialize
{
    // test recommended to avoid duplicate init via subclass
    if (self == [CameraServer class])
    {
        theServer = [[CameraServer alloc] init];
    }
}

+ (CameraServer*) server
{
    return theServer;
}

- (void) startup
{
    NSError *error;
    
    if (_session == nil)
    {
        NSLog(@"Starting up server");
        
        // create capture device with video input
        _session = [[AVCaptureSession alloc] init];
        AVCaptureDevice* dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:dev error:nil];
        [_session setSessionPreset:AVCaptureSessionPreset352x288];
        [_session addInput:input];
        
        // create an output for YUV output with self as delegate
        _captureQueue = dispatch_queue_create("uk.co.gdcl.avencoder.capture", DISPATCH_QUEUE_SERIAL);
        _output = [[AVCaptureVideoDataOutput alloc] init];
        [_output setSampleBufferDelegate:self queue:_captureQueue];
        
        /*AVCaptureConnection *conn = [_output connectionWithMediaType:AVMediaTypeVideo];
        if ([conn isVideoMaxFrameDurationSupported] && [conn isVideoMinFrameDurationSupported])
        {
            [conn setVideoMinFrameDuration:CMTimeMake(1, 15)];
            [conn setVideoMaxFrameDuration:CMTimeMake(1, 15)];
        }
        else
        {
            NSLog(@"Setting Max and/or Min frame duration is unsupported");
        }*/
        
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _output.videoSettings = setcapSettings;
        [_session addOutput:_output];
        
        [dev lockForConfiguration:&error];
        
        if(!error)
        {
            dev.activeVideoMinFrameDuration = CMTimeMake(1, 15);
            dev.activeVideoMaxFrameDuration = CMTimeMake(1, 15);
            
            [dev unlockForConfiguration];
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
        
        g_bFirst = true;
        
        // create an encoder
        _encoder = [AVEncoder encoderForHeight:288 andWidth:352];
        [_encoder encodeWithBlock:^int(NSArray* data, double pts) {
       //     if (_rtsp != nil)
       //     {
       //         _rtsp.bitrate = _encoder.bitspersecond;
        //        [_rtsp onVideoData:data time:pts];
       //     }
            [self onVideoData:data time:pts];
            return 0;
        } onParams:^int(NSData *data) {
        // _rtsp = [RTSPServer setupListener:data];
            return 0;
        }];
        
        // start capture and a preview layer
        [_session startRunning];
        
        
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // pass frame to encoder
    [_encoder encodeFrame:sampleBuffer];
}

- (void) shutdown
{
    NSLog(@"shutting down server");
    if (_session)
    {
        [_session stopRunning];
        _session = nil;
    }
 //   if (_rtsp)
 //   {
 //       [_rtsp shutdownServer];
 //   }
    if (_encoder)
    {
        [ _encoder shutdown];
    }
}

- (NSString*) getURL
{
    NSString* ipaddr = nil;
    //[RTSPServer getIPAddress];
    NSString* url = [NSString stringWithFormat:@"rtsp://%@/", ipaddr];
    return url;
}

- (AVCaptureVideoPreviewLayer*) getPreviewLayer
{
    return _preview;
}

- (void) onVideoData:(NSArray*)data time:(double)pts
{
    int i = 0;
    int nNalus = 0;
    unsigned char* pSource = NULL;
    int pSourceLen = 0;
    NSData *pNalu = NULL;
    NSData *pAVCSeqData = NULL;
    unsigned int tmpPTS = 0;
    
    if( !g_bConnect )
    {
        return;
    }
    nNalus = (int)[data count];
    for( i = 0; i < nNalus; i++ )
    {
        pNalu = [data objectAtIndex:i];
        pSource = (unsigned char*)[pNalu bytes];
        pSourceLen = (int)[pNalu length];
        if( g_bFirst )
        {
            if((pSource[0] & 0x1f) != 5)
            {
                continue;
            }
            
            pAVCSeqData = [_encoder getConfigData];
            if( pAVCSeqData == NULL )
            {
                continue;
            }
            _basePTS = pts;
            RTMPClientSendAVCSeqHeader((char*)[pAVCSeqData bytes],(int)[pAVCSeqData length],0);
            g_bFirst = false;
        }
        tmpPTS = (unsigned int)((pts-_basePTS)*1000);
        //NSLog(@"PTS is equal to %d\n", tmpPTS);
        if((pSource[0] & 0x1f) != 5)
        {
            RTMPClientSendAVCNalu((char *)pSource, pSourceLen, false, tmpPTS);
        }
        else
        {
            RTMPClientSendAVCNalu((char *)pSource, pSourceLen, true, tmpPTS);
        }
    }
}

@end

