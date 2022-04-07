FROM php:7.4-apache
#FROM php:apache

# Omeka-S web publishing platform for digital heritage collections (https://omeka.org/s/)
# Initial maintainer: Godwin Yeboah - IDG Research for Technology
LABEL maintainer_name="Godwin Yeboah"
LABEL maintainer_email="g.yeboah@warwick.ac.uk"
LABEL maintainer_email2="yeboahgodwin@gmail.com"
LABEL description="Docker for Omeka-S (version 3.1.2) \
web publishing platform for digital heritage collections (https://omeka.org/s/)."

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    unzip \
    zip \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libmcrypt-dev \
    nano \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick \
    libmagickwand-dev

# Install the PHP extensions we need
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
#RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd xml xmlrpc xmlwriter calendar json
RUN pecl install mcrypt-1.0.4 && docker-php-ext-enable mcrypt && pecl install imagick && docker-php-ext-enable imagick 

#RUN  docker-php-ext-install gd pdo pdo_mysql pdo_sqlite zip gmp bcmath pcntl ldap sysvmsg exif \
#&& a2enmod rewrite

# Add the Omeka-S PHP code
COPY ./omeka-s-3.1.2.zip /var/www/
RUN unzip -q /var/www/omeka-s-3.1.2.zip -d /var/www/ \
&&  rm /var/www/omeka-s-3.1.2.zip \
&&  rm -rf /var/www/html/ \
&&  mv /var/www/omeka-s/ /var/www/html/

COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./.htaccess /var/www/html/.htaccess

# Add some Omeka modules. If you use the next four lines (which has been disabled), make sure that in each install module, 
# you go to the 'module.ini' file and disable the "#omeka_version_constraint = "^X.X.X"" or make it '^3.0.0'. You may not be able to install if you do not do this.
# line 1
#COPY ./omeka-s-modules-v4.tar.gz /var/www/html/
# line 2 to 4
#RUN rm -rf /var/www/html/modules/ \
#&&  tar -xzf /var/www/html/omeka-s-modules-v4.tar.gz -C /var/www/html/ \
#&&  rm /var/www/html/omeka-s-modules-v4.tar.gz

# As an alternative to line 1-4 above. Install properly, Easy Install extension so that you can use that module to install others.
# the zipped file was manually compiled by selecting some modules of interest. For more modules, the 'EasyInstall' could be used to install them.
COPY ./omeka-s-modules-for-s312-collections-v2.zip /var/www/html/
RUN rm -rf /var/www/html/modules/
RUN unzip -q /var/www/html/omeka-s-modules-for-s312-collections-v2.zip -d /var/www/html/
RUN rm /var/www/html/omeka-s-modules-for-s312-collections-v2.zip
RUN cp -r /var/www/html/omeka-s-modules-for-s312-collections-v2/ /var/www/html/modules/

# Copy/Add some themes by copying downloaded zipped files from https://omeka.org/s/themes/ to themes folder
COPY ./centerrow-v1.7.3.zip ./cozy-v1.5.3.zip ./thedaily-v1.6.2.zip ./default-v1.6.3.zip ./foundation-s-v1.2.4.zip /var/www/html/themes/

# Unzip the copied zipped files in themes folder
RUN unzip -q /var/www/html/themes/centerrow-v1.7.3.zip -d /var/www/html/themes/
RUN unzip -q /var/www/html/themes/cozy-v1.5.3.zip -d /var/www/html/themes/
RUN unzip -q /var/www/html/themes/thedaily-v1.6.2.zip -d /var/www/html/themes/
#RUN unzip -q /var/www/html/themes/default-v1.6.3.zip -d /var/www/html/themes/ #There is a problem installing this one programmatically! It seems to require response as part of the unzipping process.
RUN unzip -q /var/www/html/themes/foundation-s-v1.2.4.zip -d /var/www/html/themes/

# Remove the zipped files you copied
RUN rm /var/www/html/themes/centerrow-v1.7.3.zip
RUN rm /var/www/html/themes/cozy-v1.5.3.zip
RUN rm /var/www/html/themes/thedaily-v1.6.2.zip
#RUN rm /var/www/html/themes/default-v1.6.3.zip
RUN rm /var/www/html/themes/foundation-s-v1.2.4.zip

# Create one volume for files and config
RUN mkdir -p /var/www/html/volume/config/ && mkdir -p /var/www/html/volume/files/
COPY ./database.ini /var/www/html/volume/config/
RUN rm /var/www/html/config/database.ini \
&& ln -s /var/www/html/volume/config/database.ini /var/www/html/config/database.ini \
&& rm -Rf /var/www/html/files/ \
&& ln -s /var/www/html/volume/files/ /var/www/html/files \
&& chown -R www-data:www-data /var/www/html/ \
&& chmod 600 /var/www/html/volume/config/database.ini \
&& chmod 600 /var/www/html/.htaccess

VOLUME /var/www/html/volume/

CMD ["apache2-foreground"]
