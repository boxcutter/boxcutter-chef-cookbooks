boxcutter_can
=============

Configures Controller Area Network (CAN) Bus devices.

If you get an error from modprobe that says something like this:

```
modprobe: FATAL: Module vcan not found in directory /lib/modules/6.8.0-59-generic
```

Likely you do not have the kernel module present in your kernel at all.

First try to install the kernel modules package:

```bash
sudo apt update
sudo apt install linux-modules-$(uname -r)
```

Then try again:

```bash
sudo modprobe vcan
```

If it still doesn't work, try installing the full generic kernel image:

```bash
sudo apt install linux-image-generic
sudo reboot
```

Testing vcan0
-------------

```
candump -tz vcan0 &
cansend vcan0 123#00FFAA5501020304
```
