FROM ruby:2.7-alpine
RUN apk update && apk upgrade && \
    apk add build-base && \
    rm -rf /var/cache/apk/*
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install
COPY . /app
ENV PORT=9292
CMD bundle exec puma
