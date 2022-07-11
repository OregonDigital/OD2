FROM ruby:2.7-alpine3.14 as bundler

# Necessary for bundler to operate properly
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN gem install bundler

FROM bundler as dependencies

# The alpine way
RUN apk --no-cache update && apk --no-cache upgrade && \
  apk add --no-cache alpine-sdk nodejs unzip ghostscript vim yarn \
  git sqlite sqlite-dev postgresql-dev libjpeg-turbo-dev libpng-dev \
  libtool libgomp libressl libressl-dev java-common libc6-compat  \
  curl build-base tzdata zip autoconf automake libtool texinfo \
  bash bash-completion java-common openjdk11-jre-headless graphicsmagick \
  poppler-utils ffmpeg tesseract-ocr openjpeg-dev openjpeg-tools openjpeg less\
  libffi xz gcompat

# Set the timezone to America/Los_Angeles (Pacific) then get rid of tzdata
RUN cp -f /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
  echo 'America/Los_Angeles' > /etc/timezone && apk del tzdata --purge

# Install ImageMagick with jp2/tiff support
RUN mkdir -p /tmp/im && \
  curl -sL https://www.imagemagick.org/archive/releases/ImageMagick-7.1.0-27.tar.xz \
  | tar -xJvf - -C /tmp/im && cd /tmp/im/ImageMagick-7.1.0-27 && \
    ./configure \
      --build=$CBUILD \
      --host=$CHOST \
      --prefix=/usr \
      --sysconfdir=/etc \
      --mandir=/usr/share/man \
      --infodir=/usr/share/info \
      --localstatedir=/var \
      --enable-shared \
      --disable-static \
      --with-modules \
      --with-threads \
      --with-jp2=yes \
      --with-tiff=yes \
      --with-gs-font-dir=/usr/share/fonts/Type1 \
      --with-quantum-depth=16 && \
    make -j`nproc` && \
    make install && \
    rm -rf /tmp/im

# install FITS for file characterization
RUN mkdir -p /opt/fits && \
  curl -fSL -o /opt/fits-1.5.5.zip https://github.com/harvard-lts/fits/releases/download/1.5.5/fits-1.5.5.zip && \
  cd /opt/fits && unzip /opt/fits-1.5.5.zip  && chmod +X /opt/fits/fits.sh && \
  rm -f /opt/fits-1.5.5.zip

ARG UID=8083
ARG GID=8083

# Create an app user so our program doesn't run as root.
RUN addgroup -g "$GID" app && adduser -h /data -u "$UID" -G app -D -H app

FROM dependencies as gems

# Make sure the new user has complete control over all code, including
# bundler's installed assets
RUN mkdir -p /usr/local/bundle
RUN chown -R app:app /usr/local/bundle

# Pre-install gems so we aren't reinstalling all the gems when literally any
# filesystem change happens
RUN mkdir -p /data/build
RUN chown -R app:app /data && rm -rf /data/.cache
WORKDIR /data
COPY --chown=app:app Gemfile /data
COPY --chown=app:app Gemfile.lock /data
COPY --chown=app:app build/install_gems.sh /data/build
USER app
RUN /data/build/install_gems.sh

FROM gems as code

# Add the rest of the code
COPY --chown=app:app . /data

#ARG RAILS_ENV=development
#ARG FEDORA_URL=http://fcrepo-dev:8080/fcrepo/rest
#ARG DEPLOYED_VERSION=development
ARG RAILS_ENV=${RAILS_ENV}
ENV RAILS_ENV=${RAILS_ENV}
ARG FEDORA_URL=${FEDORA_URL}
ENV FEDORA_URL=${FEDORA_URL}

FROM code

# Uninstall tools for compiling native code
USER root
RUN apk --no-cache update && apk del autoconf automake gcc g++ --purge && \
  rm -f /data/docker-compose.override.yml-example /data/README.md \
    /data/.env.example
USER app

ENV DEPLOYED_VERSION=${DEPLOYED_VERSION}

RUN if [ "${RAILS_ENV}" = "production" ]; then \
    echo "Precompiling assets with $RAILS_ENV environment"; \
    rm -rf /data/.cache; \
    RAILS_ENV=$RAILS_ENV SECRET_KEY_BASE=temporary bundle exec rails assets:precompile; \
    cp public/assets/404-*.html public/404.html; \
    cp public/assets/500-*.html public/500.html; \
  fi
