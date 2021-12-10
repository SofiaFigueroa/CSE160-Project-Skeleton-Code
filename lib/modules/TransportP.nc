#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/socket.h"

module TransportP
{
   provides interface Transport;
   uses
   {
      interface Routing as Routing;
   }
}

implementation
{
   // Iterator
   uint16_t i = 0;

   // Keeps track of sockets
   socket_t socketID = -1;    // Global
   socket_t currSocket = -1;  // Single-Use
   socket_store_t socketTable[MAX_NUM_OF_SOCKETS];

   // Actual Sockets
   socket_store_t *s;
   socket_store_t socket;

   command socket_t Transport.socket()
   {
      socketID++;

      if(socketID >= 10)
      {
         dbg(TRANSPORT_CHANNEL, "Unable to create a new socket, too many sockets. End one and try again.\n");
         return (socket_t)NULL;
      }

      return socketID;
   }

   command error_t Transport.bind(socket_t fd, socket_addr_t *addr)
   {
      return (error_t)FAIL;
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

   command void Transport.initializeServer(uint16_t node, uint16_t port)
   {
      s = &socket;

      currSocket = call Transport.socket();
      // if (currSocket == NULL) return;

      // s->
   }

   command void Transport.initialize()
   {
      dbg(TRANSPORT_CHANNEL, "Initializing Transport Layer\n");
      
      for (i = 0; i < MAX_NUM_OF_SOCKETS; i++)
      {
         s = &socket;
         s->RTT = 1 * i;
         socketTable[i] = socket;
      }

      for (i = 0; i < MAX_NUM_OF_SOCKETS; i++)
      {
         s = &socketTable[i];
         dbg(TRANSPORT_CHANNEL, "RTT of socket %d is %d\n", i, s->RTT);
      }
   }
}