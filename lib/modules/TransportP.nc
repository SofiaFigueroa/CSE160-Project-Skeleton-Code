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
   socket_store_t socket;

   void makeSocket()
   {
      socket->state = CLOSED;
      socket->src = 0;
      socket->dest = 0;
   }

   command socket_t Transport.socket()
   {

      return NULL;
   }

   command error_t Transport.bind(socket_t fd, socket_addr_t *addr)
   {
      return FAIL;
   }

   command socket_t accept(socket_t fd)
   {
      return NULL;
   }

   command uint16_t write(socket_t fd, uint8_t *buff, uint16_t bufflen)
   {
      return i;
   }

   command error_t receive(pack* package)
   {
      return FAIL;
   }

   command uint16_t read(socket_t fd, uint8_t *buff, uint16_t bufflen)
   {
      return i;
   }

   command error_t connect(socket_t fd, socket_addr_t * addr)
   {
      return FAIL;
   }

   command error_t close(socket_t fd)
   {
      return FAIL;
   }

   command error_t release(socket_t fd)
   {
      return FAIL;
   }

   command error_t listen(socket_t fd)
   {
      return FAIL;
   }
}