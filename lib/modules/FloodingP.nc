/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
   */

#include "../../includes/CommandMsg.h"

module FloodingP
{
   provides interface Flooding; // Wire module to interface
   
   uses interface SimpleSend as Sender; // Allows use of SimpleSend Interface
}

// command error_t send(pack msg, uint16_t dest );

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
   //components FloodingP;
   //CommandHandler = FloodingP;

   // What will be initially called
   command void Flooding.flood(pack *msg)
   {
      dbg(GENERAL_CHANNEL, "TESTING!");
      dbg(FLOODING_CHANNEL, "Packet recieved from %d. Destination: %d. Flooding...\n", msg->src, msg->dest);
      call Sender.send(*msg, AM_BROADCAST_ADDR);
   }

}