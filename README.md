# RTES Final Project

The goal of the final project was to implement a hardware accelerated
encryption algorithm based on Huffman coding and run it on a DE1-SoC board. The
project was part of the Real Time Embedded Systems course at EPFL in the spring
semester of 20/21.

## Building and running
To build the FPGA portion of the program you need to have Quartus 18.1
installed. Execute
```
source path_setup.sh
```
(modify the paths inside accordingly),
then launch quartus with
```
quartus
```
. Open the project file in
`hw/quartus/mini_project.qpf`. Click on Start compilation and then program the
FPGA with the Programmer tool. If the board is not detected, refresh the JTAG
connections with
```
sudo jtag_refresh.sh
```
After this, plug in a (large-ish) SD-card into your computer and find it's entry
in `/dev`. Run
```
./create_linux_system.sh /dev/<sdcard-device>
```
This script
can also build the FPGA project, but for me:
- programming from the SD-card with the .rbf file didn't work
- setting up the path for the commands needed by the script was anoying
  
I chose to program the FPGA through Quartus manually.

When the script finishes executing, the rootfs on the SD-card is only 1MB large,
which is enough for exactly one `apt install` before you run out of space. Run
```
sudo fdisk /dev/<sdcard-device>
```
and delete partition 2 with `d 2`.
Then, make a new, larger partition with the sequence
`n p 2 <default> +48G t 2 83 w` (my SD-card is 64GB, chose the size
accordingly). If you are prompted about deleting a found signature, select `No`.
Finally, run
```
sudo resize2fs /dev/<sdcard-device>p2
```
(or whatever the identifier
for partition 2 on the SD-card is). You might have to execute
```
sudo e2fsck -f /dev/<sdcard-device>p2
```
before, but you will be prompted about this.

## Missing sw directory
This repository does not contain the `sw` repository, since it was 4GB large
and contained two other repositories for Linux and U-Boot.