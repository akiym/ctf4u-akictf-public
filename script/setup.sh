#!/bin/bash

mysql -uroot -p <<EOS
CREATE USER IF NOT EXISTS 'akictf'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
CREATE DATABASE IF NOT EXISTS akictf;
GRANT ALL PRIVILEGES ON akictf.* TO 'akictf'@'localhost';
FLUSH PRIVILEGES;
EOS
mysql -uakictf akictf < sql/mysql.sql
