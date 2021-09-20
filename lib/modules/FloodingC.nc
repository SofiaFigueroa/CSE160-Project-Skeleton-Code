/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"

/*
   FloodingC sets up the Flooding module so that it can be
   called by other files. Similar to a .h file. */
configuration FloodingC
{
   provides interface Flooding; // Declare our own interface
   //uses interface SimpleSendC;
}

/*
   Write the details of neighbor discovery / flooding / whatever
   List of components we will use and how to wire them through
   potentially other functions in our module

   These lines create a component, sample, and wire it to the
   interface, Flooding.
   */
implementation
{
   // components new FloodingP();
   // Flooding = FloodingP.Flooding;
   components FloodingP;
   Flooding = FloodingP;

   components new SimpleSendC(AM_PACK) as FloodSender;
   FloodingP.Sender -> FloodSender;
}