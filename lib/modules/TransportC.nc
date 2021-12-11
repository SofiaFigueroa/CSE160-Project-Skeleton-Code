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

   components new TimerMilliC() as AcceptTimer;
   TransportP.AcceptTimer -> AcceptTimer;

   components new TimerMilliC() as newTimer;
   TransportP.newTimer -> newTimer;
}