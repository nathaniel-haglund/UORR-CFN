#!/bin/bash -xe

#System Updates
yum -y update
yum -y upgrade

#Get Mono
amazon-linux-extras install -y mono

#Get zLib
yum install -y zlib-devel.x86_64

#Get Game Files
wget --no-check-certificate --load-cookies /tmp/cookies.txt "https://drive.google.com/uc?export=download&confirm=true$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://drive.google.com/uc?export=download&id=1WgEpQSkfgn0h8dEwKXwfVPunDENbGF84' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1WgEpQSkfgn0h8dEwKXwfVPunDENbGF84" -P /home/ec2-user/ -O world.zip && rm -rf /tmp/cookies.txt

#Unpack Game Files
unzip world.zip -d /home/ec2-user/
rm world.zip

#Recompile world.exe
cd /home/ec2-user/World/Data/System
mcs -optimize+ -unsafe -t:exe -out:World.exe -nowarn:219,414 -d:NEWTIMERS -d:NEWPARENT -d:MONO -reference:System.Drawing -recurse:"Source/*.cs"
rm /home/ec2-user/World/World.exe
mv World.exe /home/ec2-user/World/World.exe

#Set Permissions
chown -R ec2-user /home/ec2-user/World
chmod 775 -R /home/ec2-user/World

#Create Swapfile
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab


#Create Cron For server
echo "@reboot ec2-user mono /home/ec2-user/World/World.exe" >> /etc/cron.d/uorrcron

#Reboot to Start Server
reboot