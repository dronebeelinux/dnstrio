# DNS Trio
## Setup a trio of integrated DNS servers using: bind9, pihole and unbound dns
Setup an authoritative DNS server using bind9, connected to a pihole instance that is forwarded to an unbound DNS server.
### Pre-requisites
These procedures assume you are using Ubuntu Linux. The steps were tested on Ubuntu 22.04.3 LTS (Jammy Jellyfish). It is recommended the target server for this installation use either static IP addresses or a DHCP reservation to achieve the same result.

Modifications have been made to the Docker networking settings to ensure a connection between the three components.
#### Update ubuntu to not use the built-resolver
```
sudo sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```
### Clone the DNS-trio Project
```
git clone https://github.com/dronebeelinux/dns-trio.git
```
#### bind9 DNS on docker
Background info on image:
https://hub.docker.com/r/ubuntu/bind9
```
cd ./dns-trio
mkdir -p ./bind/var/cache/bind
mkdir -p ./bind/var/lib/bind
sudo find ./bind -type d -exec chmod -R 755 {} \;
# NOTE: The user id 100 and gid 101 will not match to the "bind" user on Ubuntu but will inside of the Docker container.
sudo chown -R 100:101 ./bind
```
### Pihole on docker
The docker-compose.yaml for this project was originally pulled from:
https://github.com/pi-hole/docker-pi-hole
Minor modifications have been made.

The default installation of pihole will not allow connections to many websites that contain ads. If you find you are blocked right away, check the pihole query log for details.
```
# NOTE: The password exists as "password" (no quotes). Use the below command if you want to change it.
echo "password" > ./pihole/secrets/web_password.txt
```
### Unbound on docker
The docker-compose.yaml for this project was originally pulled from:
https://github.com/MatthewVance/unbound-docker
Minor modifications have been made.
### Update the environment
The settings in ```.env``` should be updated to suite your needs based on your networking and hostname requirements.
### Start the dns-trio
```
docker compose up -d
```