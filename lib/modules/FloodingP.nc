/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/protocol.h"

module FloodingP
{
    provides interface Flooding; // Wire module to interface
    uses interface SimpleSend as Sender; // Allows use of SimpleSend Interface, wired in FloodingC
    uses interface List<pack> as cache;
}

// Details of Flooding; How to call interfaces.
implementation
{
    uint16_t i = 0;
    uint16_t highestSeq = 0;
    pack fp; // floodPacket
    pack cp; // cachePacket
    pack *floodPackage = &fp;
    pack *cachePackage = &cp;

    /*
        True:   Duplicate Sequence # Found
        False:  No Duplicates Found
    */
    bool checkCacheForDuplicates(pack msg)
    {
        for (i; i < call cache.size(); i++)
        {
            cp = call cache.get(i);
            if (floodPackage->seq == cachePackage->seq)
            {
                dbg(FLOODING_CHANNEL, "Duplicate Found!\n");
                return TRUE;
            }
        }

        call cache.pushback(fp);
        return FALSE;
    }

    void setHighestSeq()
    {
        for (i; i < call cache.size(); i++)
        {
            cp = call cache.get(i);
            if (cachePackage->seq > highestSeq) highestSeq = cachePackage->seq;
        }

        floodPackage->seq = highestSeq + 1;
    }

    void decrementTTL()
    {
        floodPackage->TTL -= 1;
    }

    uint16_t getTTL()
    {
        return floodPackage->TTL;
    }

    bool readyToSend()
    {
        // Check Ping Source
        if (floodPackage->protocol == PROTOCOL_PING)
        {
            floodPackage->protocol = PROTOCOL_PINGREPLY;
            setHighestSeq();
            return TRUE;
        }

        // Check TTL
        decrementTTL();
        if (getTTL() <= 0) return FALSE;

        // Check Cache
        if (checkCacheForDuplicates(fp)) return FALSE;

        // Passed All Checks
        return TRUE;
    }
    
    // Debug Function
    void checkSourceDestination(pack* msg)
    {
        dbg(FLOODING_CHANNEL, "Source Address: %hhu, Source Dest: %hhu\n", msg->src, msg->dest);
    }

    command void Flooding.flood(pack msg)
    {
        fp = msg;
        if (readyToSend()) call Sender.send(fp, AM_BROADCAST_ADDR); // Checks TTL, Cache, etc
        logPack(floodPackage);
    }

    // Use if neighbor is known WS = With Source->Dest
    command void Flooding.floodWS(pack msg, uint16_t dest)
    {
        fp = msg;

        // Debug
        // checkSourceDestination(floodPackage);
    
        // Check TTL, Cache, etc.
        if (readyToSend()) call Sender.send(fp, dest);
    }
}