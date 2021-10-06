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
}