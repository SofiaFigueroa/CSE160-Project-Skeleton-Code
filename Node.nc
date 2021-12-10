/*
 * ANDES Lab - University of California, Merced
 * This class provides the basic functions of a network node.
 *
 * @author UCM ANDES Lab
 * @date   2013/09/03
 *
 */

#include <Timer.h>
#include "includes/command.h"
#include "includes/packet.h"
#include "includes/CommandMsg.h"
#include "includes/sendInfo.h"
#include "includes/channels.h"
#include "includes/socket.h"

module Node{
   uses
   {
      interface Boot;
      interface SplitControl as AMControl;
      interface Receive;
      interface SimpleSend as Sender;
      interface CommandHandler;

      interface Timer<TMilli> as NeighborTimer;
      interface Timer<TMilli> as RoutingTimer;

      interface Flooding;
      interface NeighborDiscovery;
      interface Routing;
      interface Transport;
   }
}

implementation
{
   pack sendPackage;
   bool packetChecked;

   void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t curr, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length)
   {
      Package->src = src;
      Package->dest = dest;
      Package->TTL = TTL;
      Package->seq = seq;
      Package->protocol = protocol;
      Package->curr = curr;
      memcpy(Package->payload, payload, length);
   }

   event void Boot.booted()
   {
      call AMControl.start();
      dbg(GENERAL_CHANNEL, "Booted\n");

      call NeighborTimer.startOneShot(500);
      call Transport.initialize();
      
      // makePack(&sendPackage, TOS_NODE_ID, AM_BROADCAST_ADDR, TOS_NODE_ID, MAX_TTL, 0, 0, "ND_PACKET", PACKET_MAX_PAYLOAD_SIZE);
      // call NeighborDiscovery.discover(sendPackage);
   }

   event void NeighborTimer.fired()
   {
      dbg(NEIGHBOR_CHANNEL, "NEIGHBOR TIMER FIRED\n");
      makePack(&sendPackage, TOS_NODE_ID, AM_BROADCAST_ADDR, TOS_NODE_ID, MAX_TTL, 0, 0, "ND_PACKET", PACKET_MAX_PAYLOAD_SIZE);
      call Flooding.flood(sendPackage);

      call RoutingTimer.startOneShot(5000);
   }

   event void RoutingTimer.fired()
   {
      dbg(ROUTING_CHANNEL, "ROUTING TIMER FIRED\n");
      makePack(&sendPackage, TOS_NODE_ID, AM_BROADCAST_ADDR, TOS_NODE_ID, MAX_TTL, PROTOCOL_LINKSTATE, 0, "LS_PACKET", PACKET_MAX_PAYLOAD_SIZE);
      call Routing.initialize(sendPackage);
      // signal CommandHandler.printLinkState();
   }

   event void AMControl.startDone(error_t err)
   {
      if (err == SUCCESS)
      {
         dbg(GENERAL_CHANNEL, "Radio On\n");
         
      }
      else
      {
         call AMControl.start(); //Retry until successful
      }
   }

   event void AMControl.stopDone(error_t err)
   {
      dbg(GENERAL_CHANNEL, "AMControl.stopDone has been triggered\n");
   }

   event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
   {
      dbg(FLOODING_CHANNEL, "Packet Received\n");

      if(len != sizeof(pack))
      {
         dbg(FLOODING_CHANNEL, "Unknown Packet Type %d\n", len);
         return msg; // Immediately escape
      }
      else
      {
         pack* myMsg = (pack*) payload;
         packetChecked = call Flooding.checkPacket(myMsg);

         if (myMsg->protocol == PROTOCOL_LINKSTATE)
         {
            // dbg(ROUTING_CHANNEL, "Checkpoint!\n");
            call Routing.log(*myMsg);
            call Flooding.flood(*myMsg);
            return msg; // escape
         }

         if (myMsg->protocol == PROTOCOL_IP)
         {
            dbg(ROUTING_CHANNEL, "IP Packet Received\n");
            // logPack(myMsg);

            if (myMsg->dest == TOS_NODE_ID && packetChecked)
            {
               dbg(GENERAL_CHANNEL, "Package Payload: %s\n", myMsg->payload);
               return msg;
            }
            else if (myMsg->dest != TOS_NODE_ID && packetChecked)
            {
               dbg(ROUTING_CHANNEL, "Not, this is for %hhu and I'm %hhu\n", myMsg->dest, TOS_NODE_ID);
               call Routing.send(*myMsg);
               return msg;
            }
         }

         if (myMsg->protocol == PROTOCOL_TCP && myMsg->dest == TOS_NODE_ID)
         {
            dbg("TCP Packet received for me, %hhu", myMsg->protocol);
            call Transport.receive(myMsg);
            return msg;
         }

         if (myMsg->dest == TOS_NODE_ID && packetChecked)
         {
            dbg(GENERAL_CHANNEL, "Package Payload: %s\n", myMsg->payload);
            return msg;
         }
         else if (myMsg->dest != TOS_NODE_ID && packetChecked)
         {
            // logPack(myMsg);
            dbg(NEIGHBOR_CHANNEL, "Got msg back from %hhu, my neighbor\n", myMsg->curr);
            
            call NeighborDiscovery.sendPacketBack(myMsg);
            // dbg(FLOODING_CHANNEL, "Not mine, flooding...\n");
            call Flooding.flood(*myMsg);
            // call Routing.send(*myMsg);
         }
      }

      dbg(FLOODING_CHANNEL, "Dropping Packet\n");
      return msg;
   }

   event void CommandHandler.ping(uint16_t destination, uint8_t *payload)
   {
      dbg(GENERAL_CHANNEL, "PING EVENT \n");

      //       pack,         int16 src,   int16 dest,  int16 curr,  i16 TTL, i16 proto,     i16 seq, i8* pl,  i8 length
      makePack(&sendPackage, TOS_NODE_ID, destination, TOS_NODE_ID, MAX_TTL, PROTOCOL_IP, 0,       payload, PACKET_MAX_PAYLOAD_SIZE);
      // call Flooding.flood(sendPackage);

      // TODO: Redo this to send through IP instead / Routing
      call Routing.send(sendPackage);
   }

   event void CommandHandler.printNeighbors()
   {
      dbg(NEIGHBOR_CHANNEL, "NEIGHBOR DUMP\n");
      call NeighborDiscovery.dumpTable();
      // return;
   }

   event void CommandHandler.printRouteTable()
   {
      dbg(ROUTING_CHANNEL, "ROUTING DUMP\n");
      call Routing.log2();

      // signal CommandHandler.printLinkState();
   }

   event void CommandHandler.printLinkState()
   {
      // dbg(ROUTING_CHANNEL, "ROUTING DUMP2\n");
      // call Routing.f();
      // call Routing.log2();
   }

   event void CommandHandler.printDistanceVector()
   {}

   event void CommandHandler.setTestServer(uint16_t port)
   {
      dbg(TRANSPORT_CHANNEL, "Server Opened by %d, Awaiting on port %d\n", TOS_NODE_ID, port);
      call Transport.initializeServer(TOS_NODE_ID, port);
   }

   event void CommandHandler.setTestClient(uint16_t destination, uint16_t srcPort, uint16_t destPort, uint16_t transfer)
   {
      dbg(TRANSPORT_CHANNEL, "Client at Node %d created. Dest: %d Source Port: %d Dest Port: %d Transfer: %d\n", TOS_NODE_ID, (uint16_t)destination, (uint16_t)srcPort, (uint16_t)destPort, (uint16_t)transfer);
      call Transport.initializeClient(destination, srcPort, destPort, transfer);
   }

   event void CommandHandler.setAppServer()
   {}

   event void CommandHandler.setAppClient()
   {}
}
