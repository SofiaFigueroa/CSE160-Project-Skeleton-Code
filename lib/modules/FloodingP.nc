/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

module FloodingP
{
    provides interface Flooding; // Wire module to interface
    uses interface SimpleSend as Sender; // Allows use of SimpleSend Interface, wired in FloodingC
    uses interface List<pack> as cache;
}

// Details of Flooding; How to call interfaces.
implementation
{
    int i = 0;
    bool flag;
    uint16_t cacheSize;
    pack cachePos;

    void checkCacheForDuplicates(pack msg)
    {
        // dbg(FLOODING_CHANNEL, "msg->src = %hhu. cache[0]->src = %hhu", msg.src, cache[0].src);
        cacheSize = call cache.size();
        cachePos = call cache.get(0);

        for (i = 0; i < cacheSize; i++)
        {
            if (msg.src == cachePos.src)
            {
                dbg(FLOODING_CHANNEL, "Match found in cache!");
                flag = FALSE;
            }

            if (i != 0) cachePos = call cache.get(i);
        }
            
        if (flag)
        {
            call cache.pushback(msg);
            dbg(FLOODING_CHANNEL, "Made it here?");
        }
    }

    command void Flooding.flood(pack msg)
    {
        typedef nx_struct FloodingHeader
        {
	        nx_uint16_t dest;
	        nx_uint16_t src;
	        nx_uint8_t payload[PACKET_MAX_PAYLOAD_SIZE];
            nx_uint8_t a[0];
        } FloodingHeader;

        if (msg.dest != TOS_NODE_ID)
        {
            dbg(FLOODING_CHANNEL,"I am %d. Packet is at %d. Destination is %d. Flooding\n", TOS_NODE_ID, msg.src, msg.dest);
            call Sender.send(msg, msg.dest);
            checkCacheForDuplicates(msg);
        }
        else
        {
            call Sender.send(msg, AM_BROADCAST_ADDR);
        }
    }
}