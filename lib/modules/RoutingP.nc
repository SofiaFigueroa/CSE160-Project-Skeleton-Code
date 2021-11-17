#include "../../includes/channels.h"

module RoutingP
{
    provides interface Routing;
    uses interface NeighborDiscovery;
    uses interface SimpleSend as Sender;
}

implementation
{
    /*  
        Routing Table, Columns 0-4 and Rows 0-15

        Columns: Destination, Next Hop, Cost, Backup, Backup Cost
        Rows: Can be changed for number of nodes in the network
    */
    
    uint16_t routingTable[5][16] = {0};
    uint16_t cachedNeighborList[16];

    uint16_t i = 0;
    uint16_t j = 0;

    command void Routing.initializeNeighbors() {}
    
    command void Routing.dumpTable()
    {
        dbg(ROUTING_CHANNEL, "Table being dumped\n");
        for (i = 0; i < 5; i++)
        {
            for (j = 0; j < 16; j++)
            {
                //dbg(ROUTING_CHANNEL, "(((%d)))", routingTable[i][j]);
            }
            //dbg(ROUTING_CHANNEL, "\n\n\n\n");
        }
    }

    void dijikstra()
    {
        return;
    }
}