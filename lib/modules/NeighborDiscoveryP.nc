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
   pack ndp; // neighborDiscoveryPacket
   pack *neighborPacket = &ndp;
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
   void setRQ(uint16_t value)
   {
      neighborPacket->r = value;
   }

   command void NeighborDiscovery.reply(pack msg)
   {
      ndp = msg;
      previousSender = getPreviousSender();
      setCurr();

      // Log that we are sending it back to the previous sender.
      dbg(NEIGHBOR_CHANNEL, "Replying back to %d, my neighbor.\n", previousSender);
      setRQ(2);
      call Flooding.floodWS(ndp, previousSender);

      // Send it along as well
      dbg(NEIGHBOR_CHANNEL, "Reply sent, now flooding.\n");
      setRQ(1);
      call Flooding.flood(ndp);
   }
}