#!/bin/bash
VALUE="$(tail -1 /etc/wireguard/wg0.conf | awk '{print $3}' | awk -F"," '{print $1}' | awk -F"." '{print $4}' | awk -F"/" '{print $1}' | head -n 1)"
WGCONF='/etc/wireguard/wg0.conf'
CLIENTS_KEY='/etc/wireguard/clients_keys/'

echo -e "\n\033[32;1;40mPlease enter a list of names separated by spaces: \033[0m"
read USER_LIST


for USER in $USER_LIST;
do

if [ -f /etc/wireguard/clients_keys/${USER}_private.key ];

then
    echo -e "\033[31;1;40m\nUser \033[0m"${USER}"\033[31;1;40m already exists, please enter another name!\033[0m\n"
else
CLIENTCONF='/etc/wireguard/clients_config/'${USER}".conf"
VALUE=$(( $VALUE + 1 ))

#Generate and output keys for users
wg genkey | tee ${CLIENTS_KEY}${USER}_private.key | wg pubkey > ${CLIENTS_KEY}${USER}_public.key
echo -e ${USER}" ip: "${VALUE}
echo -en "\033[33;1;40mPublic key: \033[0m" $USER " "
cat ${CLIENTS_KEY}${USER}_public.key 

#Adding the public key to the wire configuration
echo -e "\n#"${USER}"_config" >> ${WGCONF}
echo -e "[Peer]" >> ${WGCONF}
echo -en "Publickey = " >> ${WGCONF}
cat ${CLIENTS_KEY}${USER}_public.key >> ${WGCONF}
echo "AllowedIPs = 10.66.66."$VALUE"/32" >> ${WGCONF}

echo -en "\033[31;1;40mPrivate key: \033[0m" $USER " "
cat ${CLIENTS_KEY}${USER}_private.key

#Creating a client config
echo -e "[Interface]" >> ${CLIENTCONF}
echo -en "PrivateKey = " >> ${CLIENTCONF}
cat ${CLIENTS_KEY}${USER}_private.key >> ${CLIENTCONF}
echo "Address = 10.66.66."$VALUE"/24" >> ${CLIENTCONF}
echo "DNS = 8.8.8.8,8.8.4.4" >> ${CLIENTCONF}
echo "[Peer]" >> ${CLIENTCONF}
echo "Publickey = ENTER YOUR WG SERVER PUBLIC KEY HERE=" >> ${CLIENTCONF}
echo "Endpoint = IP:PORT WG SERVER" >> ${CLIENTCONF}
echo "AllowedIPs = 0.0.0.0/0,::/0" >> ${CLIENTCONF}  #Restriction for traffic through vpn, by default there are no restrictions and all traffic goes through vpn
fi
done
systemctl restart wg-quick@wg0.service
