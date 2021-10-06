#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

interface Flooding{
   command void flood(pack msg);
   command void floodWS(pack msg, uint16_t dest);
}