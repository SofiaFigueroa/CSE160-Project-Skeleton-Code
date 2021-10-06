//Author: UCM ANDES Lab
//$Author: abeltran2 $
//$LastChangedBy: abeltran2 $

#ifndef PACKET_H
#define PACKET_H


#include "protocol.h"
#include "channels.h"

enum{
	PACKET_HEADER_LENGTH = 12,
	PACKET_MAX_PAYLOAD_SIZE = 28 - PACKET_HEADER_LENGTH,
	MAX_TTL = 15
};


typedef nx_struct pack{
	nx_uint16_t dest;
	nx_uint16_t src;
	nx_uint16_t curr;
	nx_uint16_t seq;	//Sequence Number
	nx_uint8_t r; 		//none(0) or reQuest(1) or Reply(2)
	nx_uint8_t TTL;		//Time to Live
	nx_uint8_t protocol;
	nx_uint8_t payload[PACKET_MAX_PAYLOAD_SIZE];
}pack;

/*
 * logPack
 * 	Sends packet information to the general channel.
 * @param:
 * 		pack *input = pack to be printed.
 */
void logPack(pack *input){
	dbg(GENERAL_CHANNEL, "Curr: %hhu Src: %hhu Dest: %hhu Seq: %hhu Reply: %hhu TTL: %hhu Protocol:%hhu  Payload: %s\n",
	input->curr, input->src, input->dest, input->seq, input->r, input->TTL, input->protocol, input->payload);
}

enum{
	AM_PACK=6
};

#endif
