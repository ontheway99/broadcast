//
//  RtmpClient.c
//  broadcast
//
//  Created by Mark on 14/12/30.
//  Copyright (c) 2014年 cv. All rights reserved.
//

#include "RtmpClient.h"

#define RTMP_HEAD_SIZE   (sizeof(RTMPPacket)+RTMP_MAX_HEADER_SIZE)
extern NSMutableArray *g_pNaluBuff;

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

void RTMPClientFLVTag(char *pFrame, char *pNaluData, int nNalueDataLen, bool bIsKeyFrame)
{
    int i = 0;
    
    if( g_RTMPClient == NULL )
    {
        return;
    }
    
    if( bIsKeyFrame )
    {
        pFrame[i++] = 0x17;
    }
    else
    {
        pFrame[i++] = 0x27;
    }
    
    pFrame[i++] = 0x01;
    i = i + 3;
    
    pFrame[i++] = (nNalueDataLen >> 24) & 0xff;
    pFrame[i++] = (nNalueDataLen >> 16) & 0xff;
    pFrame[i++] = (nNalueDataLen >> 8) & 0xff;
    pFrame[i++] = nNalueDataLen & 0xff;
    
    memcpy(&pFrame[i], pNaluData, nNalueDataLen);
    i = i + nNalueDataLen;
}

int RTMPClientPacketAVCSeqHeader(char *pSrc, int nSrcLen, char *pDst, unsigned int nTimeStamp)
{
    int i = 0;
    
    if( g_RTMPClient == NULL )
    {
        return 0;
    }
    pDst[i++] = 0x17;
    pDst[i++] = 0x00;
    i = i + 3;
    
    memcpy(&pDst[i], pSrc, nSrcLen);
    i = i + nSrcLen;
    
    return i;
    
}

int RTMPClientPacketAVCNalu(char *pSrc, int nSrcLen, char *pDst, bool bIsKeyFrame, unsigned int nTimeStamp)
{
    int i = 0;
    
    if( g_RTMPClient == NULL )
    {
        return 0;
    }
    
    printf("RTMP Send AVC Nalu, Length = %d, Time Stamp = %d\n", nSrcLen, nTimeStamp);
    
    pDst = (char*)malloc(nSrcLen+9);
    if( bIsKeyFrame )
    {
        pDst[i++] = 0x17;
    }
    else
    {
        pDst[i++] = 0x27;
    }
    
    pDst[i++] = 0x01;
    i = i + 3;
    
    pDst[i++] = (nSrcLen >> 24) & 0xff;
    pDst[i++] = (nSrcLen >> 16) & 0xff;
    pDst[i++] = (nSrcLen >> 8) & 0xff;
    pDst[i++] = nSrcLen & 0xff;
    
    memcpy(&pDst[i], pSrc, nSrcLen);
    i = i + nSrcLen;
    
    return i;
}

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
    
    RTMPClientSend(chSendData, i, RTMP_PACKET_TYPE_VIDEO, nTimeStamp, RTMP_PACKET_SIZE_LARGE);
}

void RTMPClientSendAVCNalu(char *pNaluData, int nNalueDataLen, bool bIsKeyFrame, unsigned int nTimeStamp)
{
    int i = 0;
    char* pSrc = NULL;
    
    if( g_RTMPClient == NULL )
    {
        return;
    }
    
    printf("RTMP Send AVC Nalu, Length = %d, Time Stamp = %d\n", nNalueDataLen, nTimeStamp);
    pSrc = (char*)malloc(nNalueDataLen+9);
    memset(pSrc, 0, nNalueDataLen+9);
    
    if( bIsKeyFrame )
    {
        pSrc[i++] = 0x17;
    }
    else
    {
        pSrc[i++] = 0x27;
    }
    
    pSrc[i++] = 0x01;
    i = i + 3;
    
    pSrc[i++] = (nNalueDataLen >> 24) & 0xff;
    pSrc[i++] = (nNalueDataLen >> 16) & 0xff;
    pSrc[i++] = (nNalueDataLen >> 8) & 0xff;
    pSrc[i++] = nNalueDataLen & 0xff;
    
    memcpy(&pSrc[i], pNaluData, nNalueDataLen);
    i = i + nNalueDataLen;
    
    RTMPClientSend(pSrc, i, RTMP_PACKET_TYPE_VIDEO, nTimeStamp, (int)RTMP_PACKET_SIZE_LARGE);
}

void RTMPClientSendAVCNaluMed(char *pNaluData, int nNalueDataLen, bool bIsKeyFrame, unsigned int nTimeStamp)
{
    int i = 0;
    char* pSendData = NULL;
    
    if( g_RTMPClient == NULL )
    {
        return;
    }
    
    printf("RTMP Send AVC Nalu, Length = %d, Time Stamp = %d\n", nNalueDataLen, nTimeStamp);
    pSendData = (char*)malloc(nNalueDataLen+9);
    memset(pSendData, 0, nNalueDataLen+9);
    
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
    
    pSendData[i++] = (nNalueDataLen >> 24) & 0xff;
    pSendData[i++] = (nNalueDataLen >> 16) & 0xff;
    pSendData[i++] = (nNalueDataLen >> 8) & 0xff;
    pSendData[i++] = nNalueDataLen & 0xff;
    
    memcpy(&pSendData[i], pNaluData, nNalueDataLen);
    i = i + nNalueDataLen;
    
    RTMPClientSend(pSendData, i, RTMP_PACKET_TYPE_VIDEO, nTimeStamp, (int)RTMP_PACKET_SIZE_MEDIUM);
}

void RTMPClientSend(char* pData, int nDataLen, int nType, unsigned int nTimeStamp, int nHeaderType)
{
    RTMPPacket* packet = NULL;
    unsigned int nTemp = 0;
    NSData *pNalu = NULL;
    
    if( g_RTMPClient == NULL || !g_bConnect )
    {
        printf("RTMP client send fail\n");
        return;
    }
    
    nTemp = nTimeStamp - g_nOldTimeStamp;
    packet = (RTMPPacket*)malloc(RTMP_HEAD_SIZE+nDataLen);
    memset(packet, 0, RTMP_HEAD_SIZE);
    
    packet->m_body = (char *)packet + RTMP_HEAD_SIZE;
    
    packet->m_packetType = nType;
    packet->m_nBodySize = nDataLen;
    packet->m_hasAbsTimestamp = 0;
    packet->m_nTimeStamp = nTimeStamp;
    packet->m_nChannel = 4;
    packet->m_headerType = nHeaderType;
    packet->m_nInfoField2 = g_RTMPClient->m_stream_id;
    memcpy(packet->m_body, pData, nDataLen);
    
   // printf("RTMP Client Send, Length = %d, Time Stamp = %d\n", packet->m_nBodySize, packet->m_nTimeStamp);
    
    pNalu = [[NSData alloc] initWithBytes:(void*)packet length:(RTMP_HEAD_SIZE+nDataLen)];
    @synchronized(g_pNaluBuff)
    {
        [g_pNaluBuff addObject:pNalu];
    }
    
    free(packet);
}

void RTMPClientSendPacket(char *pData, int nDatalen)
{
    RTMPPacket* packet = NULL;
   
    if( g_RTMPClient == NULL || !g_bConnect )
    {
        printf("RTMP client send fail\n");
        return;
    }
    
    packet = (RTMPPacket*)malloc(nDatalen);
    memset(packet, 0, RTMP_HEAD_SIZE);
    
    memcpy(packet, pData, nDatalen);
    packet->m_body = (char *)packet + RTMP_HEAD_SIZE;
    printf("RTMP Client Send packet, Length = %d, Time Stamp = %d\n", packet->m_nBodySize, packet->m_nTimeStamp);
    RTMP_SendPacket(g_RTMPClient, (RTMPPacket*)packet, 0);
    
    free(packet);
}

