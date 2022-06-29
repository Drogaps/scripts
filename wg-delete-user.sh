#!/bin/bash
CLIENTS_KEY='/etc/wireguard/clients_keys/'

echo -e "\n\033[31;1;40mPlease enter the names of the users whose keys you want to delete \033[0m"
read DEL_USER_LIST

for USER in $DEL_USER_LIST;
do

CLIENTCONF='/etc/wireguard/clients_config/'${USER}".conf"
CLIENTLINE="$(grep -n ${USER} /etc/wireguard/wg0.conf | awk -F":" '{print $1}')"

rm ${CLIENTS_KEY}${USER}_private.key; rm ${CLIENTS_KEY}${USER}_public.key && rm ${CLIENTCONF} && 

echo -e ${USER}" was deleted" 
done

