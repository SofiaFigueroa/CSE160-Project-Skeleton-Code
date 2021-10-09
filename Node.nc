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

module Node{
   uses interface Boot;

   uses interface SplitControl as AMControl;
   uses interface Receive;

   uses interface SimpleSend as Sender;

   uses interface CommandHandler;

   uses interface Flooding;
   uses interface NeighborDiscovery;
}

implementation{
   uint16_t SEQ_IT;
   pack sendPackage;

   uint16_t temp;
   uint8_t nd = 0;
   uint8_t *nd_payload = &nd;

   // Prototypes
   void makePack(pack *Package, uint16_t curr, uint16_t src, uint16_t dest, uint8_t r, uint16_t TTL, uint16_t Protocol, uint16_t seq, uint8_t *payload, uint8_t length);

   event void Boot.booted(){
      call AMControl.start();

      dbg(GENERAL_CHANNEL, "Booted\n");
   }

   event void AMControl.startDone(error_t err){
      if(err == SUCCESS){
         dbg(GENERAL_CHANNEL, "Radio On\n");
      }else{
         //Retry until successful
         call AMControl.start();
      }
   }

   event void AMControl.stopDone(error_t err){}

   event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
      dbg(GENERAL_CHANNEL, "Packet Received\n");

      if (len == sizeof(pack))
      {
         pack* myMsg = (pack*) payload;

         // Handle Neighbor Discovery Requests/Replies
         switch (myMsg->r)
         {
            case 1:
               dbg(NEIGHBOR_CHANNEL, "Request Received \n");

               // Send a reply directly back.
               call NeighborDiscovery.reply(*myMsg);
               break;
            case 2:
               dbg(NEIGHBOR_CHANNEL, "\nReply Received \n");
               dbg(NEIGHBOR_CHANNEL, "%hhu is my neighbor. I will somehow log this information.\n", myMsg->curr);
               break;
            default:
               if (myMsg->dest == TOS_NODE_ID)
               {
                  dbg(GENERAL_CHANNEL, "Package Payload: %s\n", myMsg->payload);
               }
               else
               {
                  dbg(GENERAL_CHANNEL, "Not mine, flooding.\n");
                  myMsg->curr = TOS_NODE_ID;
                  call Flooding.flood(*myMsg);
               }

               break;
         }

         return msg;
      }
      else
      {
         dbg(GENERAL_CHANNEL, "Unknown Packet Type %d\n", len);
      }
   }

   event void CommandHandler.ping(uint16_t destination, uint8_t *payload){
      dbg(GENERAL_CHANNEL, "PING EVENT \n");

      // Make Packet: pack, curr, src, dest, r/q, TTL, protocol, seq#, payload, length
      makePack(&sendPackage, TOS_NODE_ID, TOS_NODE_ID, destination, 0, MAX_TTL, 0, 0, payload, PACKET_MAX_PAYLOAD_SIZE);
      
      // Broadcast Flood
      call Flooding.flood(sendPackage);
   }

   event void CommandHandler.printNeighbors()
   {
      dbg(NEIGHBOR_CHANNEL, "NEIGHBOR DUMP \n");

      // Make Packet: pack, curr, src, dest, r/q, TTL, protocol, seq#, payload, length
      makePack(&sendPackage, TOS_NODE_ID, TOS_NODE_ID, AM_BROADCAST_ADDR, 1, MAX_TTL, 0, 0, nd_payload, PACKET_MAX_PAYLOAD_SIZE);

      // Call Flooding.flood, but do not broadcast
      call Flooding.flood(sendPackage);

      
   }

   event void CommandHandler.printRouteTable(){}

   event void CommandHandler.printLinkState(){}

   event void CommandHandler.printDistanceVector(){}

   event void CommandHandler.setTestServer(){}

   event void CommandHandler.setTestClient(){}

   event void CommandHandler.setAppServer(){}

   event void CommandHandler.setAppClient(){}

   void makePack(pack *Package, uint16_t curr, uint16_t src, uint16_t dest, uint8_t r, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
      Package->curr = curr;
      Package->src = src;
      Package->dest = dest;
      Package->TTL = TTL;
      Package->seq = seq;
      Package->protocol = protocol;
      Package->r = r;
      memcpy(Package->payload, payload, length);
   }
}
