CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
CREATE USER IF NOT EXISTS 'liveprof'@'%' IDENTIFIED WITH mysql_native_password BY 'liveprof';
CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED WITH mysql_native_password BY 'wordpress';
CREATE USER IF NOT EXISTS 'bitrix'@'%' IDENTIFIED WITH mysql_native_password BY 'bitrix';
CREATE USER IF NOT EXISTS 'nodejs'@'%' IDENTIFIED WITH mysql_native_password BY 'nodejs';


CREATE DATABASE IF NOT EXISTS liveprof;
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE DATABASE IF NOT EXISTS bitrix;
CREATE DATABASE IF NOT EXISTS nodejs;

GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

GRANT ALL ON liveprof.* TO 'liveprof'@'%';
GRANT ALL ON wordpress.* TO 'wordpress'@'%';
GRANT ALL ON bitrix.* TO 'bitrix'@'%';
GRANT ALL ON nodejs.* TO 'nodejs'@'%';
