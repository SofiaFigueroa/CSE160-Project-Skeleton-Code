/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"

module FloodingP
{
   // uses interface <interface_name>

   provides interface Flooding; // Declare our own interface
   uses interface SimpleSend;
}

implementation
{
   /*
      Write the details of neighbor discovery / flooding / whatever
      How to CALL interfaces

      how to call <interface_name>
   */

   components FloodingP;
   CommandHandler = FloodingP;
   // For example, CommandHandlerP.Receive -> Command Receive,
   // from components new AMReceiverC(AM_COMMANDMSG) as CommandReceive;
}