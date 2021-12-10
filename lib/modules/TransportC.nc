configuration TransportC
{
   provides interface Transport;
}

implementation
{
   components TransportP;
   Transport = TransportP;

   components RoutingC;
   TransportP.Routing -> RoutingC;
}