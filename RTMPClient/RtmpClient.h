//
//  RtmpClient.h
//  broadcast
//
//  Created by Mark on 14/12/30.
//  Copyright (c) 2014年 cv. All rights reserved.
//

#ifndef __broadcast__RtmpClient__
#define __broadcast__RtmpClient__

#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import <AVFoundation/AVMediaFormat.h>

#include <memory.h>
#include <stdio.h>
#include <stdlib.h>
#include <librtmp/rtmp.h>

#define FLV_HEADER_SIZE 9

extern RTMP *g_RTMPClient;
extern bool g_bConnect;
extern bool g_bFirst;

void RTMPClientInit(void);
void RTMPClientExit(void);

bool RTMPClientConnect(char* strRTMPURL);
void RTMPClientClose(void);

void RTMPClientSend(char* pData, int nDataLen, int nType, unsigned int nTimeStamp, int nHeaderType);

void RTMPClientSendAVCSeqHeader(char *pData, int nDataLen, unsigned int nTimeStamp);
//void RTMPClientSendAVCSeqHeaderEx(char *pSPSData, int nSPSDataLen, char *pPPSData, int nPPSDataLen);
void RTMPClientSendAVCNalu(char *pNaluData, int nNalueDataLen, bool bIsKeyFrame, unsigned int nTimeStamp);
void RTMPClientSendAVCNaluMed(char *pNaluData, int nNalueDataLen, bool bIsKeyFrame, unsigned int nTimeStamp);

void RTMPClientFLVTag(char *pFrame, char *pNaluData, int nNalueDataLen, bool bIsKeyFrame);


int RTMPClientPacketAVCSeqHeader(char *pSrc, int nSrcLen, char *pDst, unsigned int nTimeStamp);
int RTMPClientPacketAVCNalu(char *pSrc, int nSrcLen, char *pDst, bool bIsKeyFrame, unsigned int nTimeStamp);


void RTMPClientSendPacket(char *pData, int nDatalen);

#endif /* defined(__broadcast__RtmpClient__) */
