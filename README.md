# DNS Trio
## Setup a trio of integrated DNS servers using: bind9, pihole and unbound dns
Setup an authoritative DNS server using bind9, connected to a pihole instance that is forwarded to an unbound DNS server.
### Pre-requisites
These procedures assume you are using Ubuntu Linux. The steps were tested on Ubuntu 22.04.3 LTS (Jammy Jellyfish). It is recommended the target server for this installation use either static IP addresses or a DHCP reservation to achieve the same result.

Modifications have been made to the Docker networking settings to ensure a connection between the three containers.
#### Update ubuntu to not use the built-in resolver
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
Reference:
https://hub.docker.com/r/ubuntu/bind9
```
cd ./dns-trio
mkdir -p ./bind/var/cache/bind
sudo find ./bind -type d -exec chmod -R 755 {} \;
```
### Pihole on docker
The docker-compose.yaml for this project was originally pulled from:
https://github.com/pi-hole/docker-pi-hole
Minor modifications have been made.

The default installation of pihole will not allow connections to many websites that contain ads. If you find you are blocked right away, check the pihole query log for details.
```
# NOTE: The password is set as "password" (no quotes). Use the below command if you want to change it.
echo "password" > ./pihole/secrets/web_password.txt
```
### Unbound on docker
Reference:
https://github.com/MatthewVance/unbound-docker

#### get root hints
```
dig +bufsize=1200 +norec NS . @a.root-servers.net | tee ~/projects/dns-trio/unbound/etc/unbound/var/root.hints
```
### Update the environment
The settings in the ```placeholder_1.env``` and ```placeholder_2.env``` files should be updated to suite your needs based on your networking and hostname requirements.
```
chmod +x replace_env.sh
vi placeholder_1.env
vi placeholder_2.env

# update DNS zone
./replace_env.sh bind/etc/bind/zones/db.domain_example.internal placeholder_1.env bind/etc/bind/zones/db.domain.internal

# update the local config file
./replace_env.sh bind/etc/bind/named.conf_example.local placeholder_1.env bind/etc/bind/named.conf.local

# update docker environment
./replace_env.sh .env_example placeholder_1.env .env

# fix permissions on bind files
# NOTE: The user id 100 and gid 101 will not match to the "bind" user on Ubuntu but will inside of the Docker container.
sudo chown -R 100:101 ./bind
```
### Start the dns-trio
```
docker compose up -d
```
### Rinse and repeat
Run these steps again on your second DNS server. Be sure to use the placeholder_2.env file instead of placeholder_1.env.
## Post install
### Point DNS clients to the new DNS trio server(s)
Use your DHCP settings on your router or wherever your friendly, neigborhood DNS settings are stored. If you made it this far, you probably know what this means and what to do. If you're not sure, check out this site for more details on how to get started: [Fix my router DNS settings](https://letmegooglethat.com/?q=how+do+i+update+the+dns+server+setting+on+my+router%3F)
### Update your pihole filters
If you have another pihole running on your network and need to import the settings, [checkout the official pihole guide here:](https://docs.pi-hole.net/core/pihole-command/?h=telepor#teleport)
## What's next?
Other ideas to consider for this project:
* making the second DNS server a "slave" server to the primary DNS server
* creating certificates for use on the pihole webserver
* automating the pihole teleport import
* is it possible to sync two pihole servers?