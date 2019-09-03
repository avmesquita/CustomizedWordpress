FROM ubuntu
MAINTAINER Andre Mesquita <avmesquita@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV MYSQL_DATABASE=wordpress 
ENV MYSQL_ROOT_PASSWORD=wordpress
ENV MYSQL_ALLOW_EMPTY_PASSWORD: "yes"

RUN echo "root:Changeme" | chpasswd

# repositories
RUN apt-get autoremove
RUN apt-get autoclean
RUN apt-get update

# install ssh and supervisord
RUN apt-get install -y curl ssh supervisor apt-utils
RUN mkdir /var/run/sshd
RUN chown root:root /var/run/sshd
RUN mkdir /var/log/supervisord

# install mysql
RUN mkdir /var/run/mysqld
RUN apt-get install -y mysql-server mysql-client 
RUN mysql -uroot -e "CREATE DATABASE wordpress;" 
RUN mysql -uroot -e "CREATE USER 'wordpress'@'%' IDENTIFIED BY 'wordpress';" 
RUN mysql -uroot -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';"
RUN	mysql -uroot -e "FLUSH PRIVILEGES;"

# install apache2 and php

RUN apt-get install -y apache2 php7.2 libapache2-mod-php7.2 php-mysql
RUN a2enmod rewrite
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername
RUN /etc/init.d/apache2 restart

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN apt-get -y install wget
RUN apt-get -y install python
RUN apt-get -y install zip unzip exif tar

# install wordpress base
RUN wget -P /var/www/html/ https://www.wordpress.org/latest.tar.gz
RUN cd /var/www/html
RUN tar -zxvf /var/www/html/latest.tar.gz -C /var/www/html
RUN mv /var/www/html/wordpress/* /var/www/html

# install plugins

#install Wordfence
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/wordfence.7.4.0.zip
RUN unzip /var/www/html/wp-content/plugins/wordfence.7.4.0.zip -d /var/www/html/wp-content/plugins/

#install Remove Query String From Static Resources
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/remove-query-strings-from-static-resources.1.4.zip
RUN unzip /var/www/html/wp-content/plugins/remove-query-strings-from-static-resources.1.4.zip -d /var/www/html/wp-content/plugins/

#instal Fast Velocity
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/fast-velocity-minify.2.7.4.zip
RUN unzip /var/www/html/wp-content/plugins/fast-velocity-minify.2.7.4.zip -d /var/www/html/wp-content/plugins/

#install Disable REST API
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/disable-json-api.1.4.3.zip
RUN unzip /var/www/html/wp-content/plugins/disable-json-api.1.4.3.zip -d /var/www/html/wp-content/plugins/

#install Google Analytics Dashboard for WP por ExactMetrics (antigo GADWP)
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/google-analytics-dashboard-for-wp.5.3.9.zip
RUN unzip /var/www/html/wp-content/plugins/google-analytics-dashboard-for-wp.5.3.9.zip -d /var/www/html/wp-content/plugins/

#install lightGallery
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/lightgallery.zip
RUN unzip /var/www/html/wp-content/plugins/lightgallery.zip -d /var/www/html/wp-content/plugins/

#install Markup (JSON-LD) structured in schema.org
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/wp-structuring-markup.4.6.5.zip
RUN unzip /var/www/html/wp-content/plugins/wp-structuring-markup.4.6.5.zip -d /var/www/html/wp-content/plugins/

# install Rename wp-login.php
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/rename-wp-login.zip
RUN unzip /var/www/html/wp-content/plugins/rename-wp-login.zip -d /var/www/html/wp-content/plugins/

# install Replace wp-admin logo
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/replace-wp-admin-logo.zip
RUN unzip /var/www/html/wp-content/plugins/replace-wp-admin-logo.zip -d /var/www/html/wp-content/plugins/

# install SEO Redirection Plugin
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/seo-redirection.zip
RUN unzip /var/www/html/wp-content/plugins/seo-redirection.zip -d /var/www/html/wp-content/plugins/

# install UpdraftPlus WordPress Backup Plugin
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/updraftplus.1.16.16.zip
RUN unzip /var/www/html/wp-content/plugins/updraftplus.1.16.16.zip -d /var/www/html/wp-content/plugins/

# install Yoast SEO
RUN wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/wordpress-seo.11.9.zip
RUN unzip /var/www/html/wp-content/plugins/wordpress-seo.11.9.zip -d /var/www/html/wp-content/plugins/

RUN rm /var/www/html/index.html
ADD htaccess /var/www/html/.htaccess
ADD wp-config.php /var/www/html/wp-config.php

RUN chown mysql:mysql /var/run/mysqld
RUN chown -R www-data /var/www
RUN chmod -R 755 /var/www

EXPOSE 22 3306 9001 80

#ENTRYPOINT
CMD ["/usr/bin/supervisord"]