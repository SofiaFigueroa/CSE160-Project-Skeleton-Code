/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"

module NeighborDiscoveryP
{
   provides interface NeighborDiscovery; // Declare our own interface
   
   uses
   {
      interface SimpleSend as Sender;
      interface Flooding as Flooding;
      interface List<uint32_t> as cache;
      interface Hashmap<uint32_t> as neighborTable;
   }
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
      –Active neighbor (yes/no)
*/

implementation
{
   // Iterator
   uint16_t i = 0;
   
   // This Module's Neighbor Packet
   pack ndp;
   pack *neighborPacket = &ndp;
   
   // Temporary Variables
   uint16_t cacheTemp;
   uint16_t previousSender;

   /* 2D Neighbor Table:
    * 3 Columns: 0=Neighbor Address, 1=Quality of Link, 2=Active Neighbor (0/1)
    * 16 Rows: Can be changed for number of nodes
    */
   uint16_t neighborTable[3][16] = {0};
   uint16_t neighborList[16];

   command void NeighborDiscovery.send(pack msg, uint16_t dest) {}

   uint16_t getPrevHop()
   {
      return neighborPacket->curr;  // Caches previous hop
   }

   void setCurrHop()
   {
      neighborPacket->curr = TOS_NODE_ID; // Sets current hop
   }

   // 0 = Ping, 1 = Request, 2 = Reply
   void setRQ(uint8_t value)
   {
      neighborPacket->r = value;
   }

   command void NeighborDiscovery.neighborDump()
   {
      // We've already received something from them
      dbg(GENERAL_CHANNEL, "I am %d. My neighbors are:\n", TOS_NODE_ID);

      for (i = 0; i < 16; i++)
      {
         if (neighborTable[0][i] != 0)
         {
            dbg(GENERAL_CHANNEL, "%d\n", neighborTable[0][i]);
         }
      }    

      return;  
   }

   command int[] NeighborDiscovery.getNeighbors() {}

   bool checkForDuplicates()
   {
      for (i = 0; i < 16; i++)
      {
         if (previousSender == neighborTable[0][i])
         {
            //dbg(NEIGHBOR_CHANNEL, "Prev: %d, Table: %d\n", previousSender, neighborTable[0][i]);
            //neighborDump(); // Debug
            return TRUE;
         }
      }

      return FALSE;
   }

   command void NeighborDiscovery.reply(pack msg)
   {
      ndp = msg;
      previousSender = getPrevHop();
      setCurrHop();

      // IF duplicate, drop packet
      if (checkForDuplicates())
      {
         dbg (NEIGHBOR_CHANNEL, "Duplicate found!\n");
         return;
      }

      neighborTable[0][previousSender] = previousSender;

      // Log that we are sending it back to the previous sender.
      dbg(NEIGHBOR_CHANNEL, "Replying back to %d, my neighbor.\n", previousSender);
      setRQ(2);
      call Sender.send(ndp, previousSender);
      logPack(neighborPacket);

      // Send it along as well
      dbg(NEIGHBOR_CHANNEL, "Reply sent, now flooding.\n");
      setRQ(1);
      call Flooding.flood(ndp);
   }
}