FROM ruby:3.2.2-slim-bookworm AS bundler

# Necessary for bundler to operate properly
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN gem install bundler -v '2.6.8'

FROM bundler AS dependencies

# The alpine way
RUN apt update && apt -y upgrade && \
  apt -y install nodejs unzip ghostscript vim less tmux yarn curl wget openssl \
  git sqlite3 postgresql-client libpq-dev libjpeg62-turbo-dev libpng-dev libtool libgomp1 \
  build-essential zip xz-utils autoconf automake libtool texinfo libltdl7 \
  bash bash-completion java-common openjdk-17-jre-headless graphicsmagick ffmpeg \
  poppler-utils tesseract-ocr libopenjp2-7-dev libopenjp2-tools libopenjp2-7 \
  libffi-dev tini libxslt1-dev libxml2-dev tzdata lsb-release cmake

# Set the timezone to America/Los_Angeles (Pacific) then get rid of tzdata
RUN cp -f /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
  echo 'America/Los_Angeles' > /etc/timezone

# Install ImageMagick with jp2/tiff support
# Install ImageMagick with full support
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
  curl -fSL -o /opt/fits-1.6.0.zip https://github.com/harvard-lts/fits/releases/download/1.6.0/fits-1.6.0.zip && \
  cd /opt/fits && unzip /opt/fits-1.6.0.zip  && chmod +X fits.sh && \
  rm -f /opt/fits-1.6.0.zip

ARG UID=8083
ARG GID=8083

# Create an app user so our program doesn't run as root.
RUN groupadd app -g $GID && useradd app -u $UID -d /data -M -g app

FROM dependencies AS gems

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

FROM gems AS code

# Add the rest of the code
COPY --chown=app:app . /data

ARG RAILS_ENV=${RAILS_ENV}
ENV RAILS_ENV=${RAILS_ENV}
ARG FEDORA_URL=${FEDORA_URL}
ENV FEDORA_URL=${FEDORA_URL}

FROM code

# Uninstall tools for compiling native code
USER root
RUN apt --purge -y autoremove autoconf automake gcc g++ tzdata && \
  rm -rf /data/docker-compose.override.yml-example /data/README.md \
  /data/.env.example /data/config/nginx /data/config/solr
USER app

ENV DEPLOYED_VERSION=${DEPLOYED_VERSION}

RUN if [ "${RAILS_ENV}" = "production" ]; then \
  echo "Precompiling assets with $RAILS_ENV environment"; \
  rm -rf /data/.cache; \
  RAILS_ENV=$RAILS_ENV SECRET_KEY_BASE=temporary bundle exec rails assets:precompile; \
  for f in public/assets/4*.html; do cp $f public/${f:14:3}.html; done; \
  fi
