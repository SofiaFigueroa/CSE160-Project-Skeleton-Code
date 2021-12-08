configuration TransportC
{
   provides interface Transport;
}

implementation
{
   components TransportP;
   Transport = TransportP;

   components RoutingC as Routing;
   TransportP.Routing = Routing;
}