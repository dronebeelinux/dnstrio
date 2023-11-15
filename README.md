# DNS Trio
## Setup a trio of integrated DNS servers using: bind9, pihole and unbound dns
### Pre-requisites
#### update ubuntu to not use resolver
https://www.linuxuprising.com/2020/07/ubuntu-how-to-free-up-port-53-used-by.html
```
sudo sed -i 's/^#DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```
#### create directories for bind server volumes
```
git clone https://github.com/dronebeelinux/dns-trio.git
cd ./dns-trio
mkdir -p ./var/cache/bind
mkdir -p ./var/lib/bind
sudo find ./var -type d -exec chmod -R 755 {} \;
sudo chown -R root:root ./config ./var
```
### pihole on docker
https://github.com/pi-hole/docker-pi-hole
```
mkdir ./etc-pihole
mkdir ./etc-dnsmasq.d
mkdir ./secrets/
echo "password" > ./secrets/web_password.txt
```
### unbound on docker
https://docs.pi-hole.net/guides/dns/unbound/
https://github.com/MatthewVance/unbound-docker
```
wget https://www.internic.net/domain/named.root -qO- | sudo tee ./unbound/root.hints
```
### start the dns-trio
```docker compose up -d
```