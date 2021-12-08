from TestSim import TestSim

def main():
    # Get simulation ready to run.
    s = TestSim();

    # Before we do anything, lets simulate the network off.
    s.runTime(10);

    # Load the the layout of the network.
    # s.loadTopo("long_line.topo");
    # s.loadTopo("lab.topo");
    s.loadTopo("example.topo");

    # Add a noise model to all of the motes.
    s.loadNoise("no_noise.txt");

    # Turn on all of the sensors.
    s.bootAll();

    s.addChannel(s.COMMAND_CHANNEL);
    s.addChannel(s.GENERAL_CHANNEL);
    s.addChannel(s.TRANSPORT_CHANNEL);
    # After sending a ping, simulate a little to prevent collision.
    s.runTime(300);
    s.testServer(1);
    s.runTime(60);
    s.testClient(4);
    s.runTime(1);
    # s.ping(3, 4, "hey");
    s.runTime(1000);

if __name__ == '__main__':
    main()
