enable
conf t
hostname Router


### SSH Config
ip ssh version 2
ip domain-name admin
crypto key generate rsa
1024
user admin privilege 15 secret cisco
line vty 0 15
transport input ssh
login local
exit
