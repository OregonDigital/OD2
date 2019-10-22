FROM ruby:2.5.5 as builder

# Necessary for bundler to operate properly
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# add nodejs and yarn dependencies for the frontend
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN gem install bundler

RUN apt-get update && apt-get upgrade -y && \
  apt-get install --no-install-recommends -y ca-certificates nodejs yarn \
  build-essential libpq-dev libreoffice imagemagick graphicsmagick unzip ghostscript vim\
  ffmpeg qt5-default libqt5webkit5-dev xvfb xauth openjdk-11-jre libopenjp2-tools --fix-missing --allow-unauthenticated

# install FITS for file characterization
RUN mkdir -p /opt/fits && \
  curl -fSL -o /opt/fits-1.0.5.zip http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip && \
  cd /opt && unzip fits-1.0.5.zip && chmod +X fits-1.0.5/fits.sh

RUN apt-get update && \
      apt-get -y install sudo

ARG UID=8083
ARG GID=8083

# Create the home directory for the new app user.
RUN mkdir -p /data
RUN chown ${UID}:${GID} /data

# Create an app user so our program doesn't run as root.
RUN groupadd -g ${GID} app
RUN useradd -g ${GID} -l -M -s /bin/false -u ${UID} app
RUN echo "app:app" | chpasswd && adduser app sudo
RUN echo "app ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/app && \
    chmod 0440 /etc/sudoers.d/app

RUN chown -R app:app /data

# Set the home directory to our app user's home.
ENV HOME=/data

WORKDIR /data

# Pre-install gems so we aren't reinstalling all the gems when literally any
# filesystem change happens
ADD Gemfile /data
ADD Gemfile.lock /data
RUN mkdir /data/build

ENV HOME=/data
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

ADD ./build/install_gems.sh /data/build
RUN ./build/install_gems.sh

# Add the application code
COPY --chown=app:app . /data

# Chown all the files to the app user.
RUN chown -R app:app /data

# Change to the app user.
USER app

FROM builder

ARG DEPLOYED_VERSION=development
ENV DEPLOYED_VERSION=${DEPLOYED_VERSION}

RUN if [ "${RAILS_ENV}" = "production" ]; then \
  echo "Precompiling assets with $RAILS_ENV environment"; \
  RAILS_ENV=$RAILS_ENV SECRET_KEY_BASE=temporary bundle exec rails assets:precompile; \
  cp public/assets/404-*.html public/404.html; \
  cp public/assets/500-*.html public/500.html; \
  fi
