#include "../../includes/packet.h"

interface NeighborDiscovery{
   command void send(pack msg, uint16_t dest );
}