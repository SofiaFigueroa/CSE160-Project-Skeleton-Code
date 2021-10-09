/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"

module NeighborDiscoveryP
{
   provides interface NeighborDiscovery; // Declare our own interface
   uses interface SimpleSend as Sender;
   uses interface Flooding as Flooding;
   uses interface List<uint16_t> as cache;
}

   /*
      This means having your own neighbor discovery
      header information that should include:
         –Request or Reply field
         –Monotonically increasing sequence number to uniquely identify the packet
         –Source address information can be obtained from the link layer

      You should have a neighbor table with three (3) fields:
         –Neighbor address
         –Quality of the link(percentage)
         –Active neighbor (yes/no) */

implementation
{
   uint16_t i = 0;
   pack ndp; // neighborDiscoveryPacket
   pack *neighborPacket = &ndp;
   //pack cp;
   //pack *cachePacket = &cp;
   uint16_t cacheTemp;
   uint16_t previousSender;

   command void NeighborDiscovery.send(pack msg, uint16_t dest)
   {
      
   }

   uint16_t getPreviousSender()
   {
      return neighborPacket->curr;      
   }

   void setCurr()
   {
      neighborPacket->curr = TOS_NODE_ID;
   }

   // 0 = Ping, 1 = Request, 2 = Reply
   void setRQ(uint8_t value)
   {
      neighborPacket->r = value;
   }

   command void NeighborDiscovery.reply(pack msg)
   {
      ndp = msg;
      previousSender = getPreviousSender();
      setCurr();

      // Check if we've already received something from them
      for (i = 0; i < call cache.size(); i++)
      {
         cacheTemp = call cache.get(i);
         if(cacheTemp == previousSender)
         {
            // We've already received something from them
            dbg(NEIGHBOR_CHANNEL, "I am %d. My neighbors currently are: ", TOS_NODE_ID);

            for (i = 0; i < call cache.size(); i++)
            {
               cacheTemp = call cache.get(i);
               dbg(NEIGHBOR_CHANNEL, "%d, \n", cacheTemp);
            }
            
            
            return;
         }

         //dbg(NEIGHBOR_CHANNEL, "cache: %d, previousSender: %d\n", cacheTemp, previousSender);
      }

      call cache.pushback(previousSender);

      // dbg(NEIGHBOR_CHANNEL, "I am %d. My neighbors currently are: ", TOS_NODE_ID);

      // for (i = 0; i < call cache.size(); i++)
      // {
      //    cacheTemp = call cache.get(i);
      //    dbg(NEIGHBOR_CHANNEL, "%d, ", cacheTemp);
      // }

      dbg(NEIGHBOR_CHANNEL, "\n");

      // Log that we are sending it back to the previous sender.
      dbg(NEIGHBOR_CHANNEL, "Replying back to %d, my neighbor.\n", previousSender);
      setRQ(2);
      //call Flooding.floodWS(ndp, previousSender);
      call Sender.send(ndp, previousSender);
      logPack(neighborPacket);

      // Send it along as well
      dbg(NEIGHBOR_CHANNEL, "Reply sent, now flooding.\n");
      setRQ(1);
      call Flooding.flood(ndp);
   }
}