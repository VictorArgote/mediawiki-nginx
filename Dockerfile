# Mediawiki-Nginx
#
# Version 1.0
FROM ubuntu:14.04
MAINTAINER Matt Renner <matt@rennernz.com>

# Ensure UTF-8
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
RUN echo deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main > /etc/apt/sources.list.d/nginx-stable-trusty.list
RUN apt-get update
RUN apt-get -y upgrade

# Install
RUN apt-get install -y nginx \
    php5-fpm php5-mysql php-apc php5-imagick php5-imap php5-mcrypt php5-gd libssh2-php

RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx-site.conf /etc/nginx/sites-available/default
RUN sed -i -e 's/^listen =.*/listen = \/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf

# Remove the old hello world app and grab Mediawiki source
RUN git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git /data

# Create the section for persistent files
RUN mkdir /var/lib/mediawiki

# Move the files that need to be persistent and create symbolic links to them
RUN mv /data/images /var/lib/mediawiki/ && ln -s /var/lib/mediawiki/images /data/images
RUN mv /data/skins /var/lib/mediawiki/ && ln -s /var/lib/mediawiki/skins /data/skins
RUN touch /var/lib/mediawiki/LocalSettings.php && ln -s /var/lib/mediawiki/LocalSettings.php /data/LocalSettings.php

VOLUME ["/var/lib/mediawiki/"]

EXPOSE 80
ADD start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]