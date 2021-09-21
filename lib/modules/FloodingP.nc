/*
   Sofia Figueroa, sfigueroa12@ucmerced.edu@ucmerced.edu
   CSE160 - Computer Networks, Fall 2021, UC Merced
*/

#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

module FloodingP
{
    provides interface Flooding; // Wire module to interface
    uses interface SimpleSend as Sender; // Allows use of SimpleSend Interface, wired in FloodingC
}

// Details of Flooding; How to call interfaces.
implementation
{
    command void Flooding.flood(pack msg)
    {
        if (msg.dest != TOS_NODE_ID) // https://catcourses.ucmerced.edu/courses/21530/files/folder/Projects/TinyOS%20Documentation?preview=4244468, Page 61
        {
            // https://stackoverflow.com/questions/39836251/how-do-i-have-a-two-way-communication-in-sensor-node-using-tinyos
            dbg(FLOODING_CHANNEL,"I am %d. Packet is at %d. Destination is %d. Flooding\n", TOS_NODE_ID, msg.src, msg.dest);
            call Sender.send(msg, msg.dest);
        }
        else
        {
            call Sender.send(msg, AM_BROADCAST_ADDR);
        }
    }
}