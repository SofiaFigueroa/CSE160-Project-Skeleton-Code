/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/protocol.h"

module NeighborDiscoveryP
{
   provides interface NeighborDiscovery; // Declare own interface

   uses
   {
      interface SimpleSend as Sender;
      interface Flooding as Flooding;
      interface Hashmap<uint16_t> as NeighborTable;
      // interface List<uint16_t> as NeighborList;
   }
}

implementation
{
   pack *sendPackage;
   pack sendBack;
   uint16_t i;
   uint16_t j;
   uint16_t neighborList[10] = {0};

   command uint16_t NeighborDiscovery.getTable(uint16_t k)
   {
      if (call NeighborTable.get(k) == 1)
      {
         // dbg(ROUTING_CHANNEL, "Returning neighbor %d\n", k);
         return k;
      }
      
      return 0;
   }

   command void NeighborDiscovery.setCurr(pack *msgCheck)
   {
      msgCheck->curr = TOS_NODE_ID;
   }

   command void NeighborDiscovery.log(uint16_t mote)
   {
      call NeighborTable.insert(mote, 1);
   }

   command void NeighborDiscovery.dumpTable()
   {
      if (call NeighborTable.isEmpty())
      {
         dbg(GENERAL_CHANNEL, "Neighbor Table is EMPTY / No Neighbors for this Node\n");
         return; // Don't waste time if the table is empty.
      }

      for (i = 0; i < MAX_NODES; i++)
      {
         if (call NeighborTable.get(i) == 1)
         {
            dbg(GENERAL_CHANNEL, "%d \n", i);
         }
      }

      return;
   }

   command void NeighborDiscovery.sendPacketBack(pack *msgBack)
   {
      msgBack->protocol = PROTOCOL_PINGREPLY;

      if (msgBack->curr != TOS_NODE_ID)
      {
         call NeighborDiscovery.log(msgBack->curr);
         call NeighborDiscovery.setCurr(msgBack); 
         call Sender.send(sendBack, msgBack->curr);
      }

      return;
   }

   command void NeighborDiscovery.discover(pack msg)
   {
      dbg(NEIGHBOR_CHANNEL, "Sending ND_PACKET\n");
      call Flooding.flood(msg);
      return;
   }
}