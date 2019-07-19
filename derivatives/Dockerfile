FROM ruby:2.5.1-alpine

RUN apk update && apk add --no-cache graphicsmagick openjpeg-tools

# Bundle early so code changes don't result in extraneous gem downloads
WORKDIR /usr/local/workers
COPY ./derivatives/Gemfile /usr/local/workers/Gemfile
COPY ./derivatives/Gemfile.lock /usr/local/workers/Gemfile.lock
RUN bundle

COPY ./derivatives /usr/local/workers

RUN mkdir -p /usr/local/oddeps/lib/oregon_digital
COPY ./lib/oregon_digital/derivative_path.rb /usr/local/oddeps/lib/oregon_digital/derivative_path.rb

ENTRYPOINT ["bundle", "exec", "sidekiq", "-r", "/usr/local/workers/jobs.rb"]
CMD ["-q", "derivatives"]
