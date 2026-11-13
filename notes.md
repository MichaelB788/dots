# notes

## virtualization

### fix external storage permissions

edit `/etc/libvirt/qemu.conf` and change the user

```bash
user = "$USER"
```

### network configuration

First, initialize the default NAT configuration using virsh

```bash
sudo virsh net-start default
```

Next, add this line to `/etc/libvirt/network.conf`

```bash
firewall_backend = "iptables"
```
