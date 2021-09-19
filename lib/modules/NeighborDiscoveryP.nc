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
      interface Receive;
      interface Queue<message_t*>
      interface Packet;
   }
}

implementation
{
   /*
      Write the details of neighbor discovery / flooding / whatever
   */
}