psql-backuping 
-
A script that backup the postgresql database, compresses it, and uploads it to s3 cloud storage. (In my case, Selectel) Also, it is possible to set up local or cloud rotation

static-etcfiles-backuping 
-
A script that creates a backup copy of the static files of the project, as well as /etc. Compresses it and uploads it to the cloud storage s3. (In my case, Selectel) You can also set up local or cloud rotation.

wg-create-user.sh
- 
A script that automates the creation of a user config and adding entries to the server config for wireguard.
It is assumed that the server config is stored by default along the path: etc/wireguard/wg0.conf
Ready client configs here: /etc/wireguard/clients_config/
The keys are here: /etc/wireguard/clients_keys/

Before use:
Generate a server config and write down Endpoint+port, as well as the wg public key of the server

If necessary, you can change AllowedIPs, dns, ip address for user config

wg-delete-user.sh
-
The script is used for easy deletion of keys and custom configurations.
Please note the script does not yet remove users from the wireguard server config
