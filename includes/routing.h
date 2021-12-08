//Author: UCM ANDES Lab
//$Author: abeltran2 $
//$LastChangedBy: abeltran2 $

#ifndef ROUTING_H
#define ROUTING_H

# include "protocol.h"
#include "channels.h"

typedef struct lsa
{
   uint16_t src[10];
   uint16_t linkState[10];
} lsa;

/*
 * logPack
 * 	Sends packet information to the general channel.
 * @param:
 * 		pack *input = pack to be printed.
 */
// void logPack(pack *input)
// {
// 	dbg(GENERAL_CHANNEL, "Src: %hhu Dest: %hhu Curr: %hhu Seq: %hhu TTL: %hhu Protocol:%hhu  Payload: %s\n",
// 	input->src, input->dest, input->curr, input->seq, input->TTL, input->protocol, input->payload);
// }

// enum
// {
// 	AM_PACK=6
// };

#endif