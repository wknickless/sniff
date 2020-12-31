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

### Netplan
Let's use [Netplan](https://netplan.io/) to configure all the network
interfaces and bridges.  We'll save the contents of
```
/etc/netplan
```
into the [netplan](netplan) directory of this repository, for reference
and fallback.

### iptables-persistent
Docker and Kubernetes really like complicated Netfilter rules, and these
rules are applied even to packets transiting bridges with no link-local
addresses applied.  But we want IPv4 and IPv6 packets to flow freely
through the bridges we're using as monitoring points.  So:
```
sudo apt install iptables-persistent
```
and save the contents of
```
/etc/iptables
```
into the [iptables](iptables) directory of this repository, for reference
and fallback.
