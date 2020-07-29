#!/bin/bash


###########################
# An automated script to install LAMP services and deploy a web Application
# Author: Ahmed Gaber
# Email: ahmed.gaberym@gmail.com
###########################



function print_color() {
  case $1 in
    "red")echo -e "\033[31m\e[1m$2";;
    "green")echo -e "\033[32m\e[1m$2";;
    *) exit 0;;
  esac
}

function print_color_underlined() {
  case $1 in
    "red")echo -e "\033\e[1m\e[4m$2[31m";;
    "yellow")echo -e "\033\e[1m\e[4m$2[33m";;
    "green")echo -e "\033\e[1m\e[4m$2[32m";;
    *) exit 0;;
  esac
}

function check_service_status() {
  chk_status=$(systemctl is-active $1)
  if [[ $chk_status -eq "active" ]]
  then
    print_color "green" "$1 is active and running"
  else
    print_color "red" "$1 is not running"
  fi
}

function check_firewall_rules() {
  chk_rule=$(sudo firewall-cmd --list-all --zone=public | grep ports)

  if [[ $chk_rule == *$1* ]]
  then
    print_color "green" "Rule applied $1"
  else
    print_color "red" "Rule is not applied $1"
  fi
}



print_color_underlined "yellow" "Deploy Pre-Requisites"
echo
echo
echo

print_color "green" "Install FirewallD"
echo
sudo yum install -y firewalld
sudo service firewalld start
sudo systemctl enable firewalld


print_color_underlined "yellow" "Deploy and Configure Database"
echo
echo
echo

print_color "green" "Install MariaDB"

sudo yum install -y mariadb-server
sudo vi /etc/my.cnf
sudo service mariadb start
sudo systemctl enable mariadb




print_color "green" "Configure firewall for Database"

sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload
check_firewall_rules 3306

print_color "green" "Configure Database"

mysql -e "CREATE DATABASE ecomdb;" -u root
mysql -e "CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';" -u root
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';" -u root
mysql -e "FLUSH PRIVILEGES;" -u root

print color "green" "Create the db-load-script.sql"

cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

mysql < db-load-script.sql


print_color_underlined "yellow" "Deploy and Configure Web Server"

sudo yum install -y httpd php php-mysql
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

check_firewall_rules 80




sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf


sudo service httpd start
sudo systemctl enable httpd



sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

check_service_status httpd
check_service_status firewalld
check_service_status mariadb 

print_color "green" "Yayy!!! :))"