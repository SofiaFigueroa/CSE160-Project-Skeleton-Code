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
   /*
      Write the details of neighbor discovery / flooding / whatever
   */

   components NeighborDiscoveryP;
   CommandHandler = NeighborDiscoveryP;
   // For example, CommandHandlerP.Receive -> Command Receive,
   // from components new AMReceiverC(AM_COMMANDMSG) as CommandReceive;
}