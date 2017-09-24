# Synopsis

Xpenology running inside a docker using KVM Virtualitzation.
The project is based on [BBVA/kvm](https://github.com/BBVA/kvm) Project.

## Features
The image provide some especial features to have the VM running the more agnostic posible
- VM DHCP: Runing VM will have DHCP and always will be provisioned with 20.20.20.21, will have internet connection and will be part of the docker networking
- Port Forwarding From container to VM, you can access to the VM using the container IP
- Live Snapshoting
- 9P Mountpoints (Access docker volumes from Xpenology)


## run Requeriments
* Host with vt-x compatibility
* KVM Module installed `modprobe kvm-intel`
* vHost Module installed `modprobe vhost-net`
* Docker installed (>1.10)

## Build
Put your xpenology img to the project folder,
rename it to synoboot.img
and execute docker build -t segator/xpenology .

## Run
Multiples environment variables can be modified to alter default runtime

#### Environment variables:
* THREADS: (Default 2) number of cpu threads per core
* CORES: (Default 2) number of cpu cores
* MEMORY: (Default 2048m) ram memory
* DISK_SIZE:(Default 101G) if you don't want to have a virtual disk set DISK_SIZE=0G
* HDD_CACHE: (Default unsafe) type of QEMU HDD Cache, click [here](https://www.ibm.com/support/knowledgecenter/en/linuxonibm/liaat/liaatbpkvmguestcache.htm) for more details

### Arguments
you can pass QEMU/KVM Arguments.
Required if you want to passthru one physical hard drive
#### Volumes:
- /image Directory where Virtual Disk's are saved (By default a virtual disk called disk.qcow2 is created to this directory)

#### Ports:
- a VNC service is listen on port 5900 (Protocol RFB 3.8)

#### Featured Functions:
The container have and extra defined functions to allow you manipulate the running VM
- VMPowerDown: This function Shutdown graceful the VM, until VM_TIMEOUT variable is reached.
- VMReset: Hard Reset the VM (this function don't stop the container)
- createSnapshot <snapshotName>: Create a Live snapshot(With memory)
- deleteSnapshot <snapshotName>: Delete a Live snapshot
- infoSnapshot: Show all the snapshots
- restoreSnapshot <snapshotName>: stop the VM and restart using the choosed snapshot

#### Mount Docker Host Volumes to Xpenology
To mount Host Path/Docker Volumes to your Xpenology Image
you need to load 9p drivers in your xpenology image,
follow [this tutorial](https://xpenology.club/compile-drivers-xpenology-with-windows-10-and-build-in-bash) to compile drivers for your specific xpenology version.
After have your image with 9p drivers loaded you need to create and script that will executed on every boot in your xpenology, this script will load
the drivers and mount your 9p mountpoint, by default  this docker image map the path /data to the 9p "hostdata"
Example
```
insmod /volume1/homes/admin/9pnet.ko
insmod /volume1/homes/admin/9pnet_virtio.ko
insmod /volume1/homes/admin/9p.ko
mkdir /volume1/\@unraid
mount -t 9p -o trans=virtio,version=9p2000.L,msize=262144  hostdata /my/host/data

```

#### Example:
`--privileged` parameter always mandatory
```
docker run --privileged -v /my/xpenology/instance:/image -p 5000:5000 segator/xpenology:6.1.3-15152
```



## Notes / TroubleShooting
* Privileged mode (`--privileged`) is needed in order for KVM to access to macvtap devices 
* If you get the following error from KVM:

  
```

qemu-kvm: -netdev tap,id=net0,vhost=on,fd=3: vhost-net requested but could not be initialized
  
qemu-kvm: -netdev tap,id=net0,vhost=on,fd=3: Device 'tap' could not be initialized

  
```


you will need to load the `vhost-net` kernel module in your dockerhost (as root) prior to launch this container:

  
```
  
# modprobe vhost-net
  
```

Sometimes on start the VM some random errors appear(I don't know why yet) 
```
cpage out of range (5)
processing error - resetting ehci HC
```
If this happen to you simple reboot the container

## License
Licensed to the Apache Software Foundation (ASF) under one or more contributor license agreements. See the NOTICE file distributed with this work for additional information regarding copyright ownership. The ASF licenses this file to you under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Contributors

Isaac Aymerich (isaac.aymerich@gmail.com)
