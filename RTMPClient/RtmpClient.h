//
//  RtmpClient.h
//  broadcast
//
//  Created by Mark on 14/12/30.
//  Copyright (c) 2014年 cv. All rights reserved.
//

#ifndef __broadcast__RtmpClient__
#define __broadcast__RtmpClient__

#include <memory.h>
#include <stdio.h>
#include <stdlib.h>
#include <librtmp/rtmp.h>

extern RTMP *g_RTMPClient;
extern bool g_bConnect;
extern bool g_bFirst;

void RTMPClientInit(void);
void RTMPClientExit(void);

bool RTMPClientConnect(char* strRTMPURL);
void RTMPClientClose(void);

void RTMPClientSend(char* pData, int nDataLen, int nType, unsigned int nTimeStamp);
void RTMPClientSendAVCSeqHeader(char *pData, int nDataLen, unsigned int nTimeStamp);
//void RTMPClientSendAVCSeqHeaderEx(char *pSPSData, int nSPSDataLen, char *pPPSData, int nPPSDataLen);
void RTMPClientSendAVCNalu(char *pNaluData, int nNalueDataLen, bool bIsKeyFrame, unsigned int nTimeStamp);

#endif /* defined(__broadcast__RtmpClient__) */
