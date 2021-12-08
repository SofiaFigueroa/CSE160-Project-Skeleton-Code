/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

configuration FloodingC
{
   provides interface Flooding;  // Declare our interface
}

// Details of Flooding. List of components we will use, and how to wire them.
implementation
{
   // Initialize FloodingP component and declare it's the interface we're providing.
   components FloodingP;
   Flooding = FloodingP;

   // Declare that we will be using the component SimpleSendC and wiring Sender to it.
   // We've declared we wanted to use Sender in FloodingP and here, we ensure connection.
   components new SimpleSendC(AM_PACK);
   FloodingP.Sender -> SimpleSendC;

   // Cache shouldn't contain more than MAX_NODES sequences in it.
   components new HashmapC(uint16_t, MAX_NODES) as seqCache;
   FloodingP.seqCache -> seqCache;
}