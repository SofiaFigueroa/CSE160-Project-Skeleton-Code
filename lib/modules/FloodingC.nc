/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"

module FloodingC
{
   provides interface Flooding; // Declare our own interface
   uses interface Receive;
   uses interface Queue<message_t*>;
   uses interface Packet;
}

implementation
{
   components FloodingP;
   Flooding = FloodingP.Flooding;
   /*
      Write the details of neighbor discovery / flooding / whatever
      List of components we will use and how to wire them through
      potentially other functions in our module
   */
}