ARG RUBY_VERSION=3.4.1
ARG APP_ROOT=/app

# base
FROM docker.io/library/ruby:$RUBY_VERSION-alpine AS base
ARG APP_ROOT
WORKDIR "$APP_ROOT"
RUN apk update && apk upgrade && \
    apk add build-base && \
    rm -rf /var/cache/apk/*
ENV BUNDLE_DEPLOYMENT="1"
ENV BUNDLE_PATH="/usr/local/bundle"
ENV BUNDLE_WITHOUT="development"

# build
FROM base AS build
RUN apk update && apk upgrade && \
    apk add build-base && \
    rm -rf /var/cache/apk/*
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# final
FROM base
ARG APP_ROOT
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build "${APP_ROOT}" "${APP_ROOT}"
COPY helpers ./helpers
COPY config ./config
COPY config.ru saml_proxy.rb LICENSE "$APP_ROOT"
RUN addgroup --system --gid 1000 samlproxy && \
    adduser --system --uid 1000 samlproxy --ingroup samlproxy && \
    chown -R samlproxy:samlproxy "$APP_ROOT"
USER samlproxy
ENV RACK_ENV=production
ENV PORT=9292
CMD ["bundle", "exec", "puma"]
