# php-cassandra
```
docker build -t php-apache-cassandra .
```
```
docker-compose up -d
```
```
docker run -d -p 8200:80 php-apache-cassandra
```

<b>Some Usefull Commands For Debugging</b>

```
php --ini
php -m | grep cassandra
echo "extension=cassandra.so" >  /usr/local/etc/php/conf.d/cassandra.ini
apachectl restart
ldd /usr/local/lib/php/extensions/no-debug-non-zts-20190902/cassandra.so
ldconfig
```
