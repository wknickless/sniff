# sniff
Configuration and scripts for full packet capture of work at home 
network traffic.

The basic idea is to put multi-port Ethernet cards in a Linux machine,
then connect pairs of Ethernet ports between points in the home network
where we want to capture traffic.  Then we will use Kubernetes StatefulSets
running containers of packet logging software to write that traffic to 
an archive drive.

## Network Configuration
Let's use [Netplan](https://netplan.io/) to configure all the network
interfaces and bridges.  We'll save the contents of
```
/etc/netplan
```
into the [netplan](netplan) directory of this repository, for reference
and fallback.

