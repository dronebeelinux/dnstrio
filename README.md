# DNS Trio
## Setup a trio of integrated DNS servers using: bind9, pihole and unbound dns
Setup an authoritative DNS server using bind9, connected to a pihole instance that is forwarded to an unbound DNS server.
### Pre-requisites
These procedures assume you are using Ubuntu Linux. The steps were tested on Ubuntu 22.04.3 LTS (Jammy Jellyfish). It is recommended the target server for this installation use either static IP addresses or a DHCP reservation to achieve the same result.
#### Update ubuntu to not use the built-resolver
```
sudo sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```
#### Clone the DNS-trio Project
```
git clone https://github.com/dronebeelinux/dns-trio.git
```
#### Create directories for bind server volumes
```
cd ./dns-trio
mkdir -p ./bind/var/cache/bind
mkdir -p ./bind/var/lib/bind
sudo find ./bind -type d -exec chmod -R 755 {} \;
# NOTE: The user id 100 and gid 101 will not match to the "bind" user on Ubuntu but will inside of the Docker image.
sudo chown -R 100:101 ./bind
```
### Pihole on docker
The docker-compose.yaml for this project was originally pulled from:
https://github.com/pi-hole/docker-pi-hole
```
# NOTE: The password exists as "password" (no quotes). Use the below command if you want to change it.
echo "password" > ./pihole/secrets/web_password.txt
```
### Unbound on docker
The docker-compose.yaml for this project was originally pulled from:
https://github.com/MatthewVance/unbound-docker
### Start the dns-trio
```
docker compose up -d
```