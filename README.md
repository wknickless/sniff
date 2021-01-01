# sniff
Configuration and scripts for full packet capture of work at home 
network traffic.

The basic idea is to 
 - Put multi-port Ethernet cards in an Ubuntu 20.04 LTS Linux machine;
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

### Wireshark
As quoted in [this article](https://packetlife.net/blog/2010/mar/19/sniffing-wireshark-non-root-user/),
WIRESHARK CONTAINS OVER ONE POINT FIVE MILLION LINES OF SOURCE CODE. DO NOT RUN THEM AS ROOT.
And, of course, we want the latest version of Wireshark from the developers.
```
sudo add-apt-repository universe
sudo add-apt-repository ppa:wireshark-dev/stable
sudo apt update
sudo apt install wireshark
```
Be sure to say "Yes" when asked to configure wireshark to run as non-root; this
will be important later on when we want to run unprivileged containers that
can sniff packets.

## Docker Container
We'll take the easy way out and simply install docker as a snap:
```
sudo snap install docker
```
But let's be a little safer by creating a revokable token on the
[Docker Hub Portal Security Tab](https://hub.docker.com/settings/security), then:
```
sudo docker login --username $DOCKER_HUB_USERNAME
```
The trivial container build scripts are in the
[netsniff-ng-container](netsniff-ng-container) directory.  Note that the
build script needs to include sudo to run correctly, because Docker.

## Archive Drive
Full time packet capture is a write-intensive, full-time workload.
Solid State Drives have limited write lifetimes, and desktop
hard drives aren't designed for a 100% duty cycle.  But
Digital Video Recorder (DVR) drives are perfect; they come in
large capacities and their designed workload assumes lots of
contiuous writing.  For this application let's use the 
Western Digital Purple 
[WD82PURZ](https://shop.westerndigital.com/tools/documentRequestHandler?docPath=/content/dam/doc-library/en_us/assets/public/western-digital/product/internal-drives/wd-purple-hdd/product-brief-wd-purple-hdd.pdf)
8TB drive.

```
$ lsscsi
[0:0:0:0]    disk    ATA      WDC WD82PURZ-85T 0A82  /dev/sda
[1:0:0:0]    cd/dvd  PLDS     DVD+-RW DU-8A5LH 6D11  /dev/sr0
[N:0:8215:1] disk    WDS500G3X0C-00SJG0__1                      /dev/nvme0n1
$ sudo mkfs.xfs /dev/sda
meta-data=/dev/sda               isize=512    agcount=8, agsize=268435455 blks
         =                       sectsz=4096  attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1
data     =                       bsize=4096   blocks=1953506646, imaxpct=5
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=521728, version=2
         =                       sectsz=4096  sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
$ sudo mkdir -p /mnt/disk/purple
$ sudo blkid /dev/sda
/dev/sda: UUID="62f188af-711c-4658-8e68-d4123f24d7ab" TYPE="xfs"
$ sudo /bin/sh -c "echo UUID=62f188af-711c-4658-8e68-d4123f24d7ab /mnt/disk/purple xfs defaults 0 0 >> /etc/fstab"
$ sudo mount -a
$ df -h /mnt/disk/purple
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda        7.3T   52G  7.3T   1% /mnt/disk/purple
```
Above we installed Wireshark to run as non-root, which means creating a
group called wireshark.  What a happy coincidence; we need a group with privileges
to write those packets to the drive!
```
sudo chgrp wireshark /mnt/disk/purple
sudo chmod 775 /mnt/disk/purple
```

## Kubernetes
### Base Configuration
Once again we'll take the easy way out and simply install the latest
stable [microk8s](https://microk8s.io):
```
sudo snap install microk8s --classic --channel=1.20/stable
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
sudo snap alias microk8s.kubectl kubectl
```
Log out and log back in to pick up the microk8s group, then:
```
microk8s enable dns storage
```

### StatefulSet sniff
Starting out with a single bridge to sniff, a simple StatefulSet
is probably reasonable:

 - [k8s/sniff-statefulset.yaml](k8s/sniff-statefulset.yaml)

## Possible improvements include:

 - Developing a Helm chart to easily parameterize the bridge name,
   storage directory, and other parameters for multiple netsniff-ng
   containers running in parallel on the same machine;
 - Spending more time to figure out and tune
   [Capabilities](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container)
   so the containers don't have to run privileged; or
 - Pull the bridge interface into the container's namespace using
   something like the CNI [host-device plugin](https://www.cni.dev/plugins/main/host-device/#example-configuration)
   (but see [mikrok8s issue 1468](https://github.com/ubuntu/microk8s/issues/1468) 
   and note that doing this will only let one process sniff a
   given bridge at a time, which might be less than optimal for
   something other than a pure full-packet-capture application; on
   the other hand, maybe multiple sniffable interfaces could be
   created using clever [Open vSwitch](https://www.openvswitch.org/)
   configurations and rules)

Pull requests welcome! :-)
