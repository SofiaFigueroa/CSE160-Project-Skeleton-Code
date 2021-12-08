#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

interface Flooding
{
   command void flood(pack msg);
   command bool checkPacket(pack *msgCheck);
   command uint16_t getNewSequenceNumber();
}