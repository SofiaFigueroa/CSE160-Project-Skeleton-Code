#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

interface Routing
{
   command void initialize(pack packet);
   command void log(pack packet);
   command void log2();
   command void send(pack packet);
}