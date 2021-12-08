#include "../../includes/packet.h"

interface NeighborDiscovery
{
   command void discover(pack msg);
   command void setCurr(pack *msgCheck);
   command void sendPacketBack(pack *msgBack);
   command void log(uint16_t mote);
   command void dumpTable();
   command uint16_t getTable(uint16_t k);
}