/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/routing.h"

configuration RoutingC
{
   provides interface Routing;  // Declare our interface
}

// Details of Routing. List of components we will use, and how to wire them.
implementation
{
   // Initialize RoutingP component and declare it's the interface we're providing.
   components RoutingP;
   Routing = RoutingP;

   components new SimpleSendC(AM_PACK);
   RoutingP.Sender -> SimpleSendC;

   components FloodingC;
   RoutingP.Flooding -> FloodingC;

   components NeighborDiscoveryC;
   RoutingP.NeighborDiscovery -> NeighborDiscoveryC;

   components new HashmapC(uint16_t, MAX_NODES) as seqCache;
   RoutingP.seqCache -> seqCache;

   components new HashmapC(lsa, MAX_NODES) as linkStates;
   RoutingP.linkStates -> linkStates;

   components new HashmapC(uint16_t, MAX_NODES) as unvisited;
   RoutingP.unvisited -> unvisited;

   components new ListC(lsa, MAX_NODES) as LS;
   RoutingP.LS -> LS;
}