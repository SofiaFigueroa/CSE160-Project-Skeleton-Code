/*
 * Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
 * CSE160 - Computer Networks, Fall 2021, UC Merced
 */

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/protocol.h"

module FloodingP
{
   provides interface Flooding;
   uses
   {
      interface SimpleSend as Sender;
      interface Packet;

      // [0,1,2,3,4,5,6...] sequence number (seq#)
      // [5,3,2,1,0,4,3...] highestSeq for each seq#
      interface Hashmap<uint16_t> as seqCache;
   }
}

implementation
{
   pack *sendPackage;

   bool checkTTL()
   {
      // Since TTL wraps around from 0 -> 255
      if (sendPackage->TTL > MAX_TTL)
      {
         dbg(FLOODING_CHANNEL, "TTL FAIL\n");
         return FALSE;
      }

      // dbg(FLOODING_CHANNEL, "TTL1 IS OKAY AND IS %hhu\n", sendPackage->TTL);
      sendPackage->TTL = sendPackage->TTL - 1;
      // dbg(FLOODING_CHANNEL, "TTL2 IS OKAY AND IS %hhu\n", sendPackage->TTL);

      return TRUE;
   }

   bool isDupe()
   {
      if(sendPackage->seq <= call seqCache.get(sendPackage->src))
      {
         dbg(FLOODING_CHANNEL, "DUPLICATE\n");
         return TRUE;
      }

      call seqCache.insert(sendPackage->src, sendPackage->seq);
      
      return FALSE;
   }

   // TRUE IF GOOD
   // FALSE IF TTL IS <0 OR IS DUPE
   command bool Flooding.checkPacket(pack *msgCheck)
   {
      sendPackage = msgCheck;
      
      if(checkTTL() && !isDupe())
      {
         msgCheck = sendPackage;
         return TRUE;
      }
      return FALSE;
   }

   command uint16_t Flooding.getNewSequenceNumber()
   {
      call seqCache.insert(TOS_NODE_ID, (call seqCache.get(TOS_NODE_ID) + 1));
      return call seqCache.get(TOS_NODE_ID);
   }

   // Assumes it's a new packet and if not, that we went through the Flooding.isPacketDupe check
   command void Flooding.flood(pack msg)
   {
      sendPackage = &msg;

      /* IF THIS IS OUR PACKET */
      if (sendPackage->src == TOS_NODE_ID)
      {
         sendPackage->seq = call Flooding.getNewSequenceNumber();
      }

      /* IF THIS IS NOT OUR PACKET */
      // TODO

      call Sender.send(msg, AM_BROADCAST_ADDR);
   }
}