FROM ruby:2.5.1
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
  build-essential libpq-dev libreoffice imagemagick unzip ghostscript vim \
  qt5-default libqt5webkit5-dev xvfb xauth openjdk-8-jre --fix-missing

# install FITS for file characterization
RUN mkdir -p /opt/fits && \
  curl -fSL -o /opt/fits-1.0.5.zip http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip && \
  cd /opt && unzip fits-1.0.5.zip && chmod +X fits-1.0.5/fits.sh

RUN mkdir /data
WORKDIR /data

# install node dependencies, after there are some included
# COPY package.json yarn.lock /data/
# RUN yarn install

# bundle gem dependencies
COPY  Gemfile Gemfile.lock /data/
RUN bundle install -j $(nproc)
