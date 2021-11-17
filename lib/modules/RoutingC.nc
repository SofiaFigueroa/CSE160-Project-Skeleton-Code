configuration RoutingC
{
    provides interface Routing;
}

implementation
{
    components RoutingP;
    Routing = RoutingP;

    components NeighborDiscoveryC;
    RoutingP.NeighborDiscovery -> NeighborDiscoveryC;
}