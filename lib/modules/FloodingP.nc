/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"

module FloodingP
{
   provides interface Flooding; // Wire module to interface
   uses interface SimpleSend; // Allows use of SimpleSend Interface
}

/*
   Write the details of neighbor discovery / flooding / whatever
   How to CALL interfaces
   how to call <interface_name>
   For example, CommandHandlerP.Receive -> Command Receive,
   from components new AMReceiverC(AM_COMMANDMSG) as CommandReceive;

   All commands provided by the interface are implemented here.
*/
implementation
{

   components FloodingP;
   CommandHandler = FloodingP;
}