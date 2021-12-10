/*
 * Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
 * CSE160 - Computer Networks, Fall 2021, UC Merced
 */

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/protocol.h"
#include "../../includes/channels.h"
#include "../../includes/routing.h"

module RoutingP
{
   provides interface Routing;
   uses
   {
      interface SimpleSend as Sender;
      interface Hashmap<uint16_t> as seqCache;
      interface Flooding as Flooding;
      interface NeighborDiscovery as NeighborDiscovery;
      interface Hashmap<lsa> as linkStates;
      interface Hashmap<uint16_t> as unvisited;
      interface List<lsa> as LS;
   }
}

implementation
{
   uint16_t neighborList[10] = {0};
   uint16_t lsaCache[10] = {0};

   // Temp holds LSA Structs
   uint16_t test[MAX_NODES] = {0};

   // Iterators
   uint16_t i;
   uint16_t j;
   uint16_t k;

   bool flag = TRUE; // keep going in algorithm loop

   uint16_t point = 0;
   uint16_t hopCount = 1;
   uint16_t prevHop = 0;

   // Packet and LSA Related
   pack *sendPackage;
   lsa linkStatePackets;
   lsa* linkSP = &linkStatePackets;

   uint16_t highestNode = 0;

   uint16_t visited[MAX_NODES] = {0};
   uint16_t unvisited[MAX_NODES] = {0};
   uint16_t nextCheck[MAX_NODES] = {0};

   // Destination, Next Hop (1), Cost (1), Backup (2), Cost (2), etc... if needed
   uint16_t routingTable[4][MAX_NODES];

   bool isNeighbor(uint16_t n)
   {
      for (j = 0; j < 10; j++)
      {
         if(n == neighborList[j]) return TRUE;
      }

      return FALSE;
   }

   void inner(uint16_t n)
   {
      linkStatePackets = call linkStates.get(n);
      linkSP = &linkStatePackets;
      memcpy(test, linkSP->linkState, PACKET_MAX_PAYLOAD_SIZE);

      for (i = 0; i < MAX_NODES; i++)
      {
         if(test[i] == 0) break;

         if(routingTable[test[i]][1] > hopCount)
         {
            routingTable[test[i]][1] = hopCount;
            if (n == TOS_NODE_ID || isNeighbor(n))
            {
               routingTable[test[i]][0] = n;
            }
            else if (isNeighbor(prevHop))
            {
               routingTable[test[i]][0] = prevHop;
            }
         }

         nextCheck[test[i]] = 1;
      }

      prevHop = n;
      visited[n] = 1;
      unvisited[n] = 0;
   }

   void dijkstra()
   {
      // Initialize Table
      for (i = 0; i < MAX_NODES; i++)
      {
         routingTable[i][1] = 1000;
         routingTable[i][0] = 0;
      }

      routingTable[TOS_NODE_ID][1] = 0;

      for (i = 1; i <= highestNode; i++) unvisited[i] = 1;

      // Initialize Algorithm
      inner(TOS_NODE_ID);

      // Continue
      while(flag == TRUE)
      {
         flag = FALSE;
         for (i = 1; i <= highestNode; i++)
         {
            if ((nextCheck[i] == 1) && nextCheck[i] != visited[i])
            {
               hopCount++;
               inner(i);
               nextCheck[i] = 0;
            }
         }
         // for (i = 1; i <= highestNode; i++) dbg(GENERAL_CHANNEL, "%d: [%d %d %d %d]\n", i, routingTable[i][0], routingTable[i][1], routingTable[i][2], routingTable[i][3]);

         for (i = 1; i <= highestNode; i++)
         {
            if (unvisited[i] == 1) flag = TRUE;
         }

         flag = FALSE;
      }

      // Cleanup

      linkStatePackets = call linkStates.get(i);
      linkSP = &linkStatePackets;
      memcpy(test, linkSP->linkState, PACKET_MAX_PAYLOAD_SIZE);

      for (i = 0; i < highestNode; i++)
      {
         if(routingTable[i][0] == 0)
         {
            routingTable[i][0] = neighborList[1];
         }
      }

      // dbg(GENERAL_CHANNEL, "Highest Node is %d\n", highestNode);
      // // Debug
      for (i = 1; i <= highestNode; i++) dbg(GENERAL_CHANNEL, "%d: [%d %d %d %d]\n", i, routingTable[i][0], routingTable[i][1], routingTable[i][2], routingTable[i][3]);
   }

   command void Routing.log(pack packet)
   {
      // Add sequence number to check for updated LSA information
      sendPackage = &packet;
      call seqCache.insert(sendPackage->src, sendPackage->seq);

      // Link state
      memcpy(linkSP->linkState, sendPackage->payload, PACKET_MAX_PAYLOAD_SIZE);
      // call LS.pushback(*linkSP);
      call linkStates.insert(sendPackage->src, *linkSP);

      return;
   }

   command void Routing.log2()
   {
      for (i = 1; i < 10; i++)
      {
         linkStatePackets = call linkStates.get(i);
         linkSP = &linkStatePackets;
         memcpy(test, linkSP->linkState, PACKET_MAX_PAYLOAD_SIZE);

         dbg(ROUTING_CHANNEL,
             "Link State Info for (node %d) : %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n",
             i, test[0], test[1], test[2], test[3], test[4], test[5], test[6], test[7], test[8], test[9]);

         for (j = 0; j < MAX_NODES; j++)
         {
            if (test[j] > highestNode) highestNode = test[j];
         }
      }
      dbg(GENERAL_CHANNEL, "Highest node is %d\n", highestNode);
      dijkstra();
   }

   uint16_t getNearestNeighbor()
   {
      call NeighborDiscovery.setCurr(sendPackage);
      linkStatePackets = call linkStates.get(sendPackage->curr);
      linkSP = &linkStatePackets;
      memcpy(test, linkSP->linkState, PACKET_MAX_PAYLOAD_SIZE);

      // Check if it's a neighbor
      for (i = 0; i < 10; i++)
      {
         if(sendPackage->dest == test[i])
         {
            dbg(ROUTING_CHANNEL, "Sending to my neighbor %d\n", sendPackage->dest);
            return sendPackage->dest;
         }
      }

      if(routingTable[sendPackage->dest][0] == 0)
      {
         // Give up, just return your first / only neighbor.
         dbg(ROUTING_CHANNEL, "I don't know who to send it to so I'm sending it to my neighbor %d\n", test[0]);
         return test[0];   
      }

      dbg(ROUTING_CHANNEL, "Sending to %d\n", routingTable[sendPackage->dest][0]);
      return routingTable[sendPackage->dest][0];
   }

   command void Routing.send(pack packet)
   {
      sendPackage = &packet;

      // Check to see if I am the sender
      if(sendPackage->seq == 0) sendPackage->seq = call Flooding.getNewSequenceNumber();
      call Sender.send(packet, getNearestNeighbor());
   }

   command void Routing.initialize(pack packet)
   {
      for (i = 0; i <= 10; i++)
      {
         if(call NeighborDiscovery.getTable(i) != 0)
         {
            neighborList[point] = i;
            point += 1;
         } 
      }

      sendPackage = &packet;
      memcpy(sendPackage->payload, neighborList, PACKET_MAX_PAYLOAD_SIZE);

      call Flooding.flood(*sendPackage);
      return;
   }
} 

// Confirmed, you can send whole table in a packet! yay! :)
// test = sendPackage->payload;
// memcpy(test, sendPackage->payload, PACKET_MAX_PAYLOAD_SIZE);
// for (i = 0; i < 10; i++)
// {
//    dbg(ROUTING_CHANNEL, "TEST: %d\n", test[i]);
// }
// Flooding.flood(packet);