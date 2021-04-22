FROM ruby:2.7-alpine as bundler

# Necessary for bundler to operate properly
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN gem install bundler

FROM bundler as dependencies

# add nodejs, yarn, and other dependencies
RUN apk add --update ca-certificates nodejs npm yarn curl git \
  g++ make libpq libreoffice imagemagick graphicsmagick unzip \
  zip ghostscript vim tesseract-ocr poppler-utils openjpeg \
  ffmpeg qt5-qtbase qt5-qtbase-dev xvfb xauth openjdk11-jre \
  postgresql-client postgresql-dev

# install FITS for file characterization
RUN mkdir -p /opt/fits && \
  curl -fSL -o /opt/fits.zip https://github.com/harvard-lts/fits/releases/download/1.5.0/fits-1.5.0.zip && \
  cd /opt && unzip fits.zip -d fits/ && chmod +X fits/fits.sh

ARG UID=8083
ARG GID=8083

# Create an app user so our program doesn't run as root.
RUN addgroup --system --gid "$GID" app && adduser -h /data -S -G app -u "$UID" app

FROM dependencies as gems

# Make sure the new user has complete control over all code, including
# bundler's installed assets
RUN mkdir -p /usr/local/bundle
RUN chown -R app:app /usr/local/bundle

# Pre-install gems so we aren't reinstalling all the gems when literally any
# filesystem change happens
RUN mkdir -p /data/build
RUN chown -R app:app /data
WORKDIR /data
COPY --chown=app:app Gemfile /data
COPY --chown=app:app Gemfile.lock /data
COPY --chown=app:app build/install_gems.sh /data/build
USER app
RUN /data/build/install_gems.sh

FROM gems as code

# Add the rest of the code
COPY --chown=app:app . /data

ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}
ARG FEDORA_URL=http://fcrepo-dev:8080/fcrepo/rest
ENV FEDORA_URL=${FEDORA_URL}

FROM code

ARG DEPLOYED_VERSION=development
ENV DEPLOYED_VERSION=${DEPLOYED_VERSION}


RUN if [ "${RAILS_ENV}" = "production" ]; then \
  echo "Precompiling assets with $RAILS_ENV environment"; \
  RAILS_ENV=$RAILS_ENV SECRET_KEY_BASE=temporary bundle exec rails assets:precompile; \
  cp public/assets/404-*.html public/404.html; \
  cp public/assets/500-*.html public/500.html; \
  yarn install; \
  fi
