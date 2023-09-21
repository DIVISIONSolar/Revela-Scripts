# Automated Scripts for Revela

# REMINDER
## MAKE SURE TO GO INTO `/root/Revela-App/node_modules/revela-frontend/public` AND EDIT THIS LINE ON THE `index.html` FILE:

```
<button class="node" title="Node ID">
        Node ID:
        <span class="node-id">CHANGE ME TO THE SERVER ID</span>
      </button>
```
## How to run

`bash <(curl -s https://raw.githubusercontent.com/DIVISIONSolar/Revela-Scripts/main/Setup/<scriptname>.sh)`

### Or you can do just download the script of choice and do this:

`chmod +x ./<name>.sh && ./<name>.sh`

# EXAMPLE:

Method 1# `bash <(curl -s https://raw.githubusercontent.com/DIVISIONSolar/Revela-Scripts/main/Setup/install.sh)`

Method #2 `wget https://raw.githubusercontent.com/DIVISIONSolar/Revela-Scripts/main/Setup/install.sh` AND `chmod +x ./install.sh && ./install.sh` 

```
<button class="node" title="Node ID">
        Node ID:
        <span class="node-id">NA.NYC.01</span>
      </button>
```
# COMMANDS:

To see the logs of the proxy run `tail -f /var/log/nginx/domain.tld.access.log`

To restart the nodes run `pm2 restart Revela`
