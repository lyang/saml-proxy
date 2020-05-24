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
ARG BUILD_DATE
ARG SOURCE
ARG REVISION
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="SamlProxy"
LABEL org.opencontainers.image.created="$BUILD_DATE"
LABEL org.opencontainers.image.source="$SOURCE"
LABEL org.opencontainers.image.revision="$REVISION"
ENV PORT=9292
CMD bundle exec puma
