ARG BASE_IMAGE=ruby:3.4-alpine
ARG APP_ROOT=/app

FROM $BASE_IMAGE AS build-env
ARG APP_ROOT
WORKDIR $APP_ROOT
RUN apk update && apk upgrade && \
    apk add build-base && \
    rm -rf /var/cache/apk/*
COPY Gemfile* ./
RUN bundle install --without=development test

FROM $BASE_IMAGE AS final
ARG APP_ROOT
ARG BUILD_DATE
ARG SOURCE
ARG REVISION
ARG BUNDLE_DIR=/usr/local/bundle
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="SamlProxy"
LABEL org.opencontainers.image.created="$BUILD_DATE"
LABEL org.opencontainers.image.source="$SOURCE"
LABEL org.opencontainers.image.revision="$REVISION"
WORKDIR $APP_ROOT
COPY --from=build-env $BUNDLE_DIR $BUNDLE_DIR
COPY . .
ENV RACK_ENV=production
ENV PORT=9292
CMD ["bundle", "exec", "puma"]
