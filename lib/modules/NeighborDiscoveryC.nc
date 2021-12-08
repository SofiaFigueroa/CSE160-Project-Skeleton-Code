/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

configuration NeighborDiscoveryC
{
   provides interface NeighborDiscovery; // Declare our own interface
}

implementation
{
   components NeighborDiscoveryP;
   NeighborDiscovery = NeighborDiscoveryP;

   components new SimpleSendC(AM_PACK);
   NeighborDiscoveryP.Sender -> SimpleSendC;

   components FloodingC;
   NeighborDiscoveryP.Flooding -> FloodingC;

   components new HashmapC(uint16_t, MAX_NODES) as NeighborTable;
   NeighborDiscoveryP.NeighborTable -> NeighborTable;

   // components new ListC(uint16_t, MAX_NODES) as NeighborList;
   // NeighborDiscoveryP.NeighborList -> NeighborList;

   // components new ListC(uint32_t, 16) as cache;
   // NeighborDiscoveryP.cache -> cache;
}