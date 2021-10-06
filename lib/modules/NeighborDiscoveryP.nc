/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"

module NeighborDiscoveryP
{
   provides interface NeighborDiscovery; // Declare our own interface
   uses interface SimpleSend as Sender;
}

implementation
{
   /*
      This means having your own neighbor discovery
      header information that should include:
         –Request or Reply field
         –Monotonically increasing sequence number to uniquely identify the packet
         –Source address information can be obtained from the link layer

      You should have a neighbor table with three (3) fields:
         –Neighbor address
         –Quality of the link(percentage)
         –Active neighbor (yes/no) */

   
}