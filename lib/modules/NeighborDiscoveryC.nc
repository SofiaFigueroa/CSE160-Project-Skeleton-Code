/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"

module NeighborDiscoveryC
{
   provides interface NeighborDiscovery; // Declare our own interface
}

implementation
{
   components new NeighborDiscoveryP();
   NeighborDiscovery = NeighborDiscoveryP.NeighborDiscovery;
   
   void NeighborDiscovery.send()
   {
      
   }
}