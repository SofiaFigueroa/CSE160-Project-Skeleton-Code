#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

interface Flooding{
   command void flood(pack msg);
   //void checkCacheForDuplicates();
}