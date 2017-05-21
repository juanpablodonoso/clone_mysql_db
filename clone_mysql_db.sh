#!/bin/bash
# author: Pablo Donoso - github.com 
# Make a clone of a DB stored in another server from mysql dumpfile 
set -e 

# ====== Secondary machine part =====
mysql_dump_file='/tmp/contactos.sql';
master_server_ip='192.168.56.101'; 

echo "---> Copying the dumpfile from master server with IP: $master_server_ip";
 
# check rsync execution  
# view EXITS CODES at rysync man
rsync_command=`rsync -avz -e ssh $master_server_ip:$mysql_dump_file $mysql_dump_file`
if [ $rsync_command -ne 0 ]; then
        echo "Error: Error in rsync execution with code $?. Please check ERROR CODES in rsync's man'"; 
        exit 1;
fi

# check if the file exists in directory  
if ! [ -e `echo $mysql_dump_file`  ]; then   
        echo "Error: The dump file $mysql_dump_file does not exist."; 
        exit 1;
fi

# create MySQL database in remote machine
echo "--> Creating the database"
echo "--> Insert the user MySQL password"
read mysql_password
mysql -u root --password="$mysql_password"  -e "create database 'contactos';"
mysql -u root --password="$mysql_password" -e "quit"
mysql -u root --password="$mysql_password" contactos < echo `$mysql_dump_file`
