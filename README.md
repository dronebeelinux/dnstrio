# DNS Trio
## Setup a trio of integrated DNS servers using: bind9, pihole and unbound dns
### Pre-requisites
#### update ubuntu to not use resolver
Background info:
https://www.linuxuprising.com/2020/07/ubuntu-how-to-free-up-port-53-used-by.html
```
sudo sed -i 's/^#DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```
#### clone project
```
git clone https://github.com/dronebeelinux/dns-trio.git
```
#### create directories for bind server volumes
```
cd ./dns-trio
mkdir -p ./bind/var/cache/bind
mkdir -p ./bind/var/lib/bind
sudo find ./bind -type d -exec chmod -R 755 {} \;
sudo chown -R 100:101 ./bind
```
### pihole on docker
Background info:
https://github.com/pi-hole/docker-pi-hole
The password exists as "password" (no quotes). Use the below command if you want to change it.
```
echo "password" > ./pihole/secrets/web_password.txt
```
### unbound on docker
Background info:
https://docs.pi-hole.net/guides/dns/unbound/
https://github.com/MatthewVance/unbound-docker
### start the dns-trio
```
docker compose up -d
```