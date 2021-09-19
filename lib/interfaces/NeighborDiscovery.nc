#include "../../includes/packet.h"

interface NeighborDiscovery{
   command error_t send(pack msg, uint16_t dest );
}