FROM ubuntu:14.04

MAINTAINER Brandon Plasters, bmilesp@gmail.com

VOLUME ["/var/www/html"]

RUN apt-get update --fix-missing
RUN apt-get upgrade -y

RUN apt-get install -y openssh-server apache2 supervisor php5 php5-cli libapache2-mod-php5 php5-gd php5-json php5-ldap php5-mysql php5-pgsql openssl php-pear php5-dev php5-mongo
RUN mkdir -p /var/run/sshd
#RUN mkdir -p /var/log/supervisor

RUN useradd ubuntu -d /home/ubuntu
RUN mkdir -p /home/ubuntu/.ssh
RUN chmod 700 /home/ubuntu/.ssh
RUN chown ubuntu:ubuntu /home/ubuntu/.ssh

#ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
RUN a2enmod ssl
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^error_reporting\s*=.*$/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^error_reporting\s*=.*$/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^PermitRootLogin.*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -e "\$aextension=mongo.so" /etc/php5/apache2/php.ini

ADD supervisord.conf /etc/supervisor/supervisord.conf
#ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD run /usr/local/bin/
RUN chmod +x /usr/local/bin/run

ADD ag.ugp.conf /etc/apache2/sites-available/ag.ugp.conf
ADD pos.ugp.conf /etc/apache2/sites-available/pos.ugp.conf
ADD pogo.ugp.conf /etc/apache2/sites-available/pogo.ugp.conf
#ADD stations.p.conf /etc/apache2/sites-available/stations.p.conf

ADD dummy.crt /etc/apache2/
ADD dummy.key /etc/apache2/

RUN a2ensite ag.ugp pos.ugp pogo.ugp 

EXPOSE 22 80 443 
CMD ["/usr/local/bin/run"]