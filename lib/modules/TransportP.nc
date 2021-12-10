#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/socket.h"

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
   // Iterator
   uint16_t i = 0;

   // Keeps track of sockets
   socket_t socketID = -1;                              // Global IDs
   socket_t currSocket = -1;                            // Single-Use Purpose
   socket_store_t socketTable[MAX_NUM_OF_SOCKETS];      // Stores sockets
   uint16_t socketsInUse[MAX_NUM_OF_SOCKETS] = {0};     // Stores socketIDs
   uint16_t acceptedSockets[MAX_NUM_OF_SOCKETS] = {0};  // Stores active connections

   // Actual Sockets
   socket_store_t *s;
   socket_store_t socket;

   // Socket Port Struct
   socket_port_t socketPort;

   // Socket Addr Struct
   socket_addr_t *sa;
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
      return (error_t)SUCCESS;
      // return (error_t)FAIL;
   }

   command socket_t Transport.accept(socket_t fd)
   {
      return (socket_t)NULL;
   }

   command uint16_t Transport.write(socket_t fd, uint8_t *buff, uint16_t bufflen)
   {
      return i;
   }

   command error_t Transport.receive(pack* package)
   {
      return FAIL;
   }

   command uint16_t Transport.read(socket_t fd, uint8_t *buff, uint16_t bufflen)
   {
      return i;
   }

   command error_t Transport.connect(socket_t fd, socket_addr_t * addr)
   {
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
      return (error_t)FAIL;
   }

   command void Transport.initializeClient()
   {
      // s = &socket;
      
      // currentSocket = call Transport.socket(); // Get socketID


      // s->RTT = 5;
      // s->flag = 4;
      // dbg(TRANSPORT_CHANNEL, "From this socket, RTT is %d and Flag is %d\n", s->RTT, s->flag);
   }

   event void AcceptTimer.fired()
   {
      dbg(TRANSPORT_CHANNEL, "No longer listening\n", currSocket);

      
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

         socketPort = port;            // Set socket_port

         sa = &socketAddr;             // Set socket_addr
         sa->port = port;              // Set socket_addr port
         sa->addrp = node;             // Set socket_addr node

         // Add port and addr information to our socket info
         s->src = socketPort;
         s->dest = socketAddr;

         // For test client, currSocket is 0/8 and sa->addrp is TOS_NODE_ID
         dbg(TRANSPORT_CHANNEL, "Binding to Socket %d from Address %d\n", currSocket, sa->addrp);
         
         if (call Transport.bind(currSocket, sa) == (error_t)FAIL)
         {
            dbg(TRANSPORT_CHANNEL, "Unable to Bind! Can't Initialize.\n");
            return;
         }
         else
         {
            // 3 second timer
            call AcceptTimer.startOneShot(3000);
            dbg(TRANSPORT_CHANNEL, "Binded to %d. Listening...\n", currSocket);
         }
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