# DNS Trio
## Setup a trio of integrated DNS servers using containers
Setup an authoritative DNS server using bind9, connected to a Pi-hole instance that is forwarded to an unbound DNS server. The approach is to be your own DNS rather than forwarding all your DNS traffic out to the wide-world web. The Docker networking settings create a connection between the three containers running on each server.

The general flow for the DNS queries is: 
Client -> BindDNS -> Pi-hole DNS -> Unbound DNS. Your environment may include a router other network device as well. 
### Pre-requisites
These procedures assume you are using Ubuntu Linux. The steps were tested on Ubuntu 22.04.3 LTS (Jammy Jellyfish). It is recommended the target server for this installation use either static IP addresses or a DHCP reservation to achieve the same result.

Docker and docker compose are also required. The steps below will help setup the Linux machine for success.
### Update Ubuntu to not use the built-in resolver
```
sudo sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```
### Install Docker
Steps adopted from official [Docker documentation](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository). If you're looking for fewer steps, there is a shorter version from Docker [here](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script). Prepare the repository:
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
Install Docker and docker compose:
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
Run your favorite hello-world app:
```
sudo docker run hello-world
```
Create the docker group:
```
sudo groupadd docker
```
Add your favorite user to the docker group:
```
sudo usermod -aG docker $USER
```
Once completed, you can log out and log back in so that your group membership is checked again. If you're feeling fancy, just type ```bash``` to run up a new shell and keep going.
### Clone the DNS Trio Project
```
git clone https://github.com/dronebeelinux/dns-trio.git
```
### bind9 DNS on docker
Reference:
https://hub.docker.com/r/ubuntu/bind9
```
cd ./dns-trio
mkdir -p ./bind/var/cache/bind
find ./bind -type d -exec chmod -R 755 {} \;
```
### Update the environment
The settings in the ```env1.env``` and ```env2.env``` files can be updated to suite your needs based on your networking and hostname requirements. If no changes are made, the result will be a new domain with the name ```example.internal```. Use ```env1.env``` on the first DNS server and ```env2.env``` (steps below) on the second DNS server.
```
# make updates for the first environment. keep it simple and don't get crazy

# set the environment to match

export DNSENV=env1

# edit the environment as needed

vi ${DNSENV}.env
```
Run the ```replace_env.sh``` script to update the environment:
```
# update permissions to include execute on the script:

chmod +x replace_env.sh

# update the example zone configuration:

./replace_env.sh bind/etc/bind/zones/db.domain_example.internal ${DNSENV}.env bind/etc/bind/zones/db.domain.internal

# update the local zone config file:

./replace_env.sh bind/etc/bind/named.conf_example.local ${DNSENV}.env bind/etc/bind/named.conf.local

# update the options file:

./replace_env.sh bind/etc/bind/named.conf_example.options ${DNSENV}.env bind/etc/bind/named.conf.options

# update docker environment:

./replace_env.sh .env_example ${DNSENV}.env .env

# update permissions on bind files. do not complete these steps until you're sure you're done with modifying the bind config and zone files:

# NOTE: the user id 100 and gid 101 will not match to the "bind" user on the Ubuntu Linux host but will inside of the Docker container

sudo chown -R 100:101 ./bind
```
### Pi-hole on docker
The docker-compose.yaml for this project was originally pulled from
[here](https://github.com/pi-hole/docker-pi-hole). Minor modifications have been made.

The default installation of pi-hole will not allow connections to many websites that contain ads, including ye old social media sites. If you find you are blocked right away, check the pi-hole query log for details.
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
## Rinse and repeat (optional for a second DNS server)
Run the same steps again on your second DNS server. Be sure to use the env2.env file instead of env1.env. Remember, one is none and two is one.
```
# make updates for the second environment. keep it simple and don't get crazy and don't overlap the IP ranges with the first.

# set the environment to match

export DNSENV=env2

# edit the environment as needed

vi ${DNSENV}.env
```
From here, scroll back up and run the commands again under the second environment. Look for "update the example zone configuration" above.
## Start the dns-trio
```
docker compose up -d
```
## Test for a good query
Check your favorite website to make sure DNS resolves as expected. If you know the local IP, this fancy command isn't really needed:
```
dig webhamster.com @$(hostname -I | awk '{print $1}')

# if you can't dig it, try nslookup

nslookup webhamster.com $(hostname -I | awk '{print $1}')
```
## Post install
Consider these steps after your DNS is up and running
### Point DNS clients to the new DNS trio server(s)
Use your DHCP settings on your router or wherever your friendly, neigborhood DNS settings are stored. If you made it this far, you probably know what this means and what to do. If you're not sure, check out this site for more details on how to get started: [Fix my router DNS settings](https://letmegooglethat.com/?q=how+do+i+update+the+dns+server+setting+on+my+router%3F)
### Update your pi-hole filters
If you have another pi-hole running on your network and need to import the settings, [checkout the official pi-hole guide here:](https://docs.pi-hole.net/core/pihole-command/?h=telepor#teleport)
## What's next?
Other ideas to consider for this project:
* making the second DNS server a "slave" server to the primary DNS server
* creating certificates for use on the Pi-hole webserver
* automating the Pi-hole teleport import
* is it possible to sync two Pi-hole servers?

What would you do? Any suggestions? Feel free to contribute or share your thoughts. I am always open to new ideas!