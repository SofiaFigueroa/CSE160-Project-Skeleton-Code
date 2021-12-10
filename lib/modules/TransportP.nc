#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/socket.h"
#include "../../includes/protocol.h"

module TransportP
{
   provides interface Transport;
   uses
   {
      interface Routing as Routing;
      interface Timer<TMilli> as AcceptTimer;
   }
}

implementation
{
   // Ints
   uint16_t i = 0;
   uint16_t temp = 0;

   // Package handler
   pack *sendPackage;
   pack packet;

   // Keeps track of sockets
   socket_t acceptedSocket = -1;                        // Global IDs
   socket_t currSocket = -1;                            // Single-Use Purpose
   socket_store_t socketTable[MAX_NUM_OF_SOCKETS];      // Stores sockets
   uint16_t socketsInUse[MAX_NUM_OF_SOCKETS] = {0};     // Stores socketIDs
   uint16_t portsBySocket[MAX_NUM_OF_SOCKETS] = {0};    // Stores active connections by port
   pack inbox[MAX_NUM_OF_SOCKETS] = {0};                // Stores incoming TCP packets
   uint16_t portsInUse[MAX_NUM_OF_SOCKETS] = {-1};                      // Up to 100 ports? Sure.

   // Actual Sockets
   socket_store_t *s;
   socket_store_t *s2;
   socket_store_t socket;

   // Socket Port Struct
   socket_port_t socketPort;
   socket_port_t socketPortTemp;

   // Socket Addr Struct
   socket_addr_t *destInfo;
   socket_addr_t socketAddr;

   command socket_t Transport.socket()
   {
      for(i = 0; i < MAX_NUM_OF_SOCKETS; i++)
      {
         if(socketsInUse[i] == 0) return i;
      }

      dbg(TRANSPORT_CHANNEL, "Unable to create a new socket, all are in use.\n");
      return (socket_t)NULL;
   }

   command error_t Transport.bind(socket_t fd, socket_addr_t *addr)
   {
      // Accidentally implemented without using this function
      return (error_t)SUCCESS;
   }

   command socket_t Transport.accept(socket_t fd)
   {


      return (socket_t)NULL;
   }

   command uint16_t Transport.write(socket_t fd, uint8_t *buff, uint16_t bufflen)
   {
      return i;
   }

   // A packet is received and we confirmed it was a TCP packet for us!
   command error_t Transport.receive(pack* package)
   {
      // logPack(package);
      // Let's make sure we have pointers!
      memcpy(s, package->payload, SOCKET_BUFFER_SIZE);   // Pointers to the socket payload 
      destInfo = &s->dest;                               // Pointers to the destination info (currently it's server info)

      // Hard coded for now.
      // inbox[0] = &package;
      // sendPackage = &inbox[0];
      // logPack(sendPackage);

      inbox[0] = *package;
      logPack(&inbox[0]);
      temp = 1;

      dbg(TRANSPORT_CHANNEL, "Success from receive! Package came in and has src %hhu, dest %hhu, and for port %d\n",package->src,destInfo->addrp,destInfo->port);
      return (error_t)SUCCESS;
   }

   command uint16_t Transport.read(socket_t fd, uint8_t *buff, uint16_t bufflen)
   {
      return i;
   }

   void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol)
   {
      Package->src = src;
      Package->dest = dest;
      Package->TTL = TTL;
      // Package->seq = seq;
      Package->protocol = protocol;
   }

   command error_t Transport.connect(socket_t fd, socket_addr_t * addr)
   {
      // We take a look into the socket table at the socket number provided.
      // For project 3, we're just looking at socket number 0.
      s = &socketTable[fd];
      destInfo = &s->dest;

      // Begin creating our packet to send to our destination server we want to connect to
      sendPackage = &packet;
      memcpy(sendPackage->payload, s, PACKET_MAX_PAYLOAD_SIZE);
      makePack(sendPackage, TOS_NODE_ID, destInfo->addrp, MAX_TTL, PROTOCOL_TCP); // TODO: Sequence number, connect to NeighborC.

      // Send our packet over. It contains general information about source and destination
      // It also contains the socket and all of it's information such as srcPort, destPort, etc.
      dbg(TRANSPORT_CHANNEL, "Sending packet to %d from port %d to port %d\n", destInfo->addrp, s->src, destInfo->port);
      call Routing.send(packet);

      return (error_t)FAIL;
   }

   command error_t Transport.close(socket_t fd)
   {
      return (error_t)FAIL;
   }

   command error_t Transport.release(socket_t fd)
   {
      return (error_t)FAIL;
   }

   command error_t Transport.listen(socket_t fd)
   {
      // Currently trying to see if a TCP connection has come for one of our ports in use.
      if (temp == 0)
      {
         dbg(TRANSPORT_CHANNEL, "No packet found in inbox\n");
         return (error_t)FAIL;
      }
      else
      {
         dbg(TRANSPORT_CHANNEL, "Packet found!\n");
         return (error_t)SUCCESS; 
      }
   }

   command void Transport.initializeClient(uint16_t dest, uint16_t srcPort, uint16_t destPort, uint16_t transfer)
   {
      // Get a new socket
      currSocket = call Transport.socket();
      
      if (currSocket != (socket_t)NULL)
      {
         dbg(TRANSPORT_CHANNEL, "Unable to Initialize Client\n");
         return;
      }
      else
      {
         // We are now going to use that socket.
         socketsInUse[currSocket] = 1;
         s = &socketTable[currSocket];

         //========== TRANSPORT.BIND ==========//

         // Set destination info. Port is destination port, addrp is destination address
         destInfo = &socketAddr;      
         destInfo->port = destPort;   
         destInfo->addrp = dest;      

         // Add port and addr information to our socket info
         s->src = destPort;       // Source Info
         s->dest = socketAddr;   // Dest Info

         //======== END TRANSPORT.BIND ========//

         // Connect to the node by sending them a packet with our socket information as the payload
         call Transport.connect(currSocket, destInfo);
         dbg(TRANSPORT_CHANNEL, "Attempting connection...\n");
      }
   }

   event void AcceptTimer.fired()
   {
      // We've found our packet in our inbox!
      if (call Transport.listen(currSocket) == (error_t)SUCCESS)
      {
         logPack(&inbox[0]);
         // dbg(TRANSPORT_CHANNEL, "Success from listen! Found incoming connection attempt from %hhu, from srcPort %d to destPort %d\n", sendPackage->src, s->src, destInfo->port);
         call AcceptTimer.stop();
      }
   }

   void logSockets()
   {
      for (i = 0; i < MAX_NUM_OF_SOCKETS; i++) dbg(TRANSPORT_CHANNEL, "socketsInUse[%d] = %d\n", i, socketsInUse[i]);
   }

   command void Transport.initializeServer(uint16_t node, uint8_t port)
   {
      currSocket = call Transport.socket();
      dbg(TRANSPORT_CHANNEL, "Using socket %d/%d\n", currSocket, MAX_NUM_OF_SOCKETS);

      if (currSocket != (socket_t)NULL)
      {
         dbg(TRANSPORT_CHANNEL, "Unable to Initialize Server\n");
         return;
      }
      else
      {
         socketsInUse[currSocket] = 1; // Mark socket as in use
         s = &socketTable[currSocket]; // Get socket from correct slot
         
         // The port our socket is connecting us to is currently going to be busy.
         for(i = 0; i < 100; i++)
         {
            if (portsInUse[i] = -1)
            {
               portsInUse[i] = port;
               portsBySocket[currSocket] = port; // Saves 40 to index 0
               break;
            }
         }       

         //========== TRANSPORT.BIND ==========//

         destInfo = &socketAddr;
         
         // Set's our source as the server port
         // The client will know server address
         s->src = port;

         // Sets socket 0 to 40 in this test case.
         socketsInUse[currSocket] = port;

         
         //======== END TRANSPORT.BIND ========//

         // For test server, currSocket is 0/8 and destInfo->addrp is TOS_NODE_ID
         dbg(TRANSPORT_CHANNEL, "Binding port %d to Socket %d from Address %d\n", port, currSocket, destInfo->addrp);
         
         if (call Transport.bind(currSocket, destInfo) == (error_t)FAIL)
         {
            dbg(TRANSPORT_CHANNEL, "Unable to Bind! Can't Initialize.\n");
            return; // This shouldn't happen due to bind() not doing anything.
         }
         else
         {
            // 3 second timer
            call AcceptTimer.startPeriodic(3000);
            dbg(TRANSPORT_CHANNEL, "Binded to %d. Listening...\n", currSocket);
         }

         // logSockets();
      }
   }

   command void Transport.initialize()
   {
      dbg(TRANSPORT_CHANNEL, "Initializing Transport Layer\n");
      
      for (i = 0; i < MAX_NUM_OF_SOCKETS; i++)
      {
         socketTable[i] = socket;
      }
   }
}