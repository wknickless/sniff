# sniff
Configuration and scripts for full packet capture of work at home 
network traffic.

The basic idea is to 
 - Put multi-port Ethernet cards in a Linux machine;
 - Connect pairs of Ethernet ports between points in the home network
   where we want to capture traffic;
 - Use Linux kernel bridging between the Ethernet port pairs;
 - Install a Digital Video Recorder (DVR) rated hard drive to
   store all the captured packets; and
 - Set up Kubernetes StatefulSets running packet capture software
   to capture packets from the Linux bridges and write them to the
   DVR-rated hard drive.

## Network Configuration
Let's use [Netplan](https://netplan.io/) to configure all the network
interfaces and bridges.  We'll save the contents of
```
/etc/netplan
```
into the [netplan](netplan) directory of this repository, for reference
and fallback.

