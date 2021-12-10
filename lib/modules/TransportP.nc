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
   uint16_t i = 0;

   socket_store_t *s;
   socket_store_t socket;

   // Keeps track of sockets
   socket_t socketID = -1;
   socket_t currentSocket = 0;

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
      dbg(TRANSPORT_CHANNEL, "Checkpoint 1\n");
      currentSocket = call Transport.socket(); // Get socket
      dbg(TRANSPORT_CHANNEL, "Checkpoint 2\n");
      s->RTT = 5;
      dbg(TRANSPORT_CHANNEL, "Socket flag is %d\n", s->RTT);
   }

   command void Transport.initializeServer()
   {

   }
}