//
//  RtmpClient.c
//  broadcast
//
//  Created by Mark on 14/12/30.
//  Copyright (c) 2014年 cv. All rights reserved.
//

#include "RtmpClient.h"

RTMP *g_RTMPClient = NULL;
bool g_bConnect = false;
bool g_bFirst = false;
unsigned int g_nOldTimeStamp = 0;

void RTMPClientInit(void)
{
    g_RTMPClient = RTMP_Alloc();
    RTMP_Init(g_RTMPClient);
}

void RTMPClientExit(void)
{
    RTMP_Free(g_RTMPClient);
    g_RTMPClient = NULL;
}

bool RTMPClientConnect(char* strRtmpURL)
{
    int nErr = 0;
    
    
    if( g_RTMPClient == NULL )
    {
        return false;
    }
    
    if( strRtmpURL == NULL)
    {
        return false;
    }
    
    nErr = RTMP_SetupURL(g_RTMPClient, strRtmpURL);
    if(nErr <= 0)
    {
        return false;
    }
    
    RTMP_EnableWrite(g_RTMPClient);
    
    nErr = RTMP_Connect(g_RTMPClient, NULL);
    if(nErr <= 0)
    {
        printf("RTMP can't connect URL %s!\n", strRtmpURL);
        return false;
    }
    
    nErr = RTMP_ConnectStream(g_RTMPClient, NULL);
    if(nErr <= 0)
    {
        printf("RTMP can't connect stream!\n");
        return false;
    }
    
    g_bConnect =true;
    return true;
}

void RTMPClientClose(void)
{
    g_bConnect = false;
    RTMP_Close(g_RTMPClient);
}

void RTMPClientSend(char* pData, int nDataLen, int nType, unsigned int nTimeStamp)
{
    RTMPPacket* packet = NULL;
    unsigned int nTemp = 0;
    
    if( g_RTMPClient == NULL || !g_bConnect )
    {
        printf("RTMP client send fail\n");
        return;
    }
    
    //if( g_nOldTimeStamp == nTimeStamp )
    //    return;
    //g_nOldTimeStamp = nTimeStamp;
    
    nTemp = nTimeStamp - g_nOldTimeStamp;
    //if( (nTimeStamp !=0) && (nTemp == 0) )
     //   return;
    printf("Time stamp is %d\n", nTemp);
    g_nOldTimeStamp = nTimeStamp;
    
    packet = (RTMPPacket*)malloc(sizeof(RTMPPacket));
    RTMPPacket_Reset(packet);
    if( ! RTMPPacket_Alloc(packet, nDataLen) )
    {
        printf("RTMP packet alloc fail, data length = %d\n", nDataLen);
        return;
    }
    
    packet->m_packetType = nType;
    packet->m_nBodySize = nDataLen;
    packet->m_nTimeStamp = nTemp;
    packet->m_nChannel = 4;
    packet->m_headerType = RTMP_PACKET_SIZE_LARGE;
    packet->m_nInfoField2 = g_RTMPClient->m_stream_id;
    memcpy(packet->m_body, pData, nDataLen);
    
    RTMP_SendPacket(g_RTMPClient, packet, 0);
  //  printf("RTMP send packet. Type = %d, DataLen = %d\n", nType, nDataLen);
    
    RTMPPacket_Free(packet);
    free(packet);
}

/*void RTMPClientSendAVCSeqHeaderEx(char *pSPSData, int nSPSDataLen, char *pPPSData, int nPPSDataLen)
{
    int i = 0;
    char chSendData[1024] = { 0 };
    
    chSendData[i++] = 0x17;
    chSendData[i++] = 0x00;
    i = i + 3;

    chSendData[i++] = 0x01;
    chSendData[i++] = pSPSData[1];
    chSendData[i++] = pSPSData[2];
    chSendData[i++] = pSPSData[3];
    chSendData[i++] = 0xFF;
    chSendData[i++] = 0xE1;
    chSendData[i++] = nSPSDataLen >> 8;
    chSendData[i++] = nSPSDataLen & 0xff;
    memcpy(&chSendData[i], pSPSData, nSPSDataLen);
    i = i + nSPSDataLen;
    
    chSendData[i++] = 0x01;
    chSendData[i++] = nSPSDataLen >> 8;
    chSendData[i++] = nPPSDataLen & 0xff;
    memcpy(&chSendData[i], pPPSData, nPPSDataLen);
    i = i + nPPSDataLen;
    
    RTMPClientSend(chSendData, i, RTMP_PACKET_TYPE_VIDEO, 0);
}*/

void RTMPClientSendAVCSeqHeader(char *pData, int nDataLen, unsigned int nTimeStamp)
{
    int i = 0;
    char chSendData[1024] = { 0 };
    
    if( g_RTMPClient == NULL )
    {
        return;
    }
    chSendData[i++] = 0x17;
    chSendData[i++] = 0x00;
    i = i + 3;
    
    memcpy(&chSendData[i], pData, nDataLen);
    i = i + nDataLen;
    
    RTMPClientSend(chSendData, i, RTMP_PACKET_TYPE_VIDEO, nTimeStamp);
}

void RTMPClientSendAVCNalu(char *pNaluData, int nNalueDataLen, bool bIsKeyFrame, unsigned int nTimeStamp)
{
    int i = 0;
    char* pSendData = NULL;
    
    if( g_RTMPClient == NULL )
    {
        return;
    }
    
    pSendData = (char*)malloc(nNalueDataLen+9);
    if( bIsKeyFrame )
    {
        pSendData[i++] = 0x17;
    }
    else
    {
        pSendData[i++] = 0x27;
    }
    
    pSendData[i++] = 0x01;
    i = i + 3;
    
    pSendData[i++] = nNalueDataLen >> 24;
    pSendData[i++] = nNalueDataLen >> 16;
    pSendData[i++] = nNalueDataLen >> 8;
    pSendData[i++] = nNalueDataLen & 0xff;
    
    memcpy(&pSendData[i], pNaluData, nNalueDataLen);
    i = i + nNalueDataLen;
    
    RTMPClientSend(pSendData, i, RTMP_PACKET_TYPE_VIDEO, nTimeStamp);
}

