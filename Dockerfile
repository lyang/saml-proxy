ARG BASE_IMAGE=ruby:2.7-alpine
ARG APP_ROOT=/app
ARG BUNDLE_DIR=/usr/local/bundle

FROM $BASE_IMAGE AS build-env

ARG APP_ROOT
ARG BUNDLE_DIR

ENV BUNDLE_PATH=$BUNDLE_DIR
ENV BUNDLE_BIN=$BUNDLE_DIR/bin
ENV PATH="${BUNDLE_BIN}:${PATH}"

WORKDIR $APP_ROOT

# 1. Install dependencies needed to compile native extensions (Nokogiri)
RUN apk update && apk add --no-cache \
    build-base \
    libxml2-dev \
    libxslt-dev \
    xz-dev \
    zlib-dev

# 2. Update rubygems and bundler for better compatibility with modern gems
RUN gem update --system 3.4.22 && gem install bundler -v 2.4.22

# 3. Install Gems
COPY Gemfile* ./

# 4. Ensure lock + install resolve the same way
RUN bundle config set --global path "$BUNDLE_PATH" && \
    bundle config set --global without "development test" && \
    bundle config set --global force_ruby_platform true && \
    bundle lock --add-platform ruby && \
    bundle lock --remove-platform aarch64-linux x86_64-linux aarch64-linux-musl x86_64-linux-musl || true && \
    bundle install && \
    rm -rf .bundle/config && \
    rm -rf $BUNDLE_PATH/cache/*.gem


FROM $BASE_IMAGE AS final

ARG APP_ROOT
ARG BUNDLE_DIR
ARG BUILD_DATE
ARG SOURCE
ARG REVISION

ENV BUNDLE_PATH=$BUNDLE_DIR
ENV BUNDLE_BIN=$BUNDLE_DIR/bin
ENV BUNDLE_WITHOUT="development:test"
ENV BUNDLE_FORCE_RUBY_PLATFORM=true
ENV BUNDLE_IGNORE_CONFIG=true
ENV BUNDLE_FROZEN=true
ENV GEM_HOME=$BUNDLE_DIR
ENV PATH="${BUNDLE_BIN}:${PATH}"
ENV RACK_ENV=production
ENV PORT=9292

WORKDIR $APP_ROOT

# 1. Install RUNTIME dependencies (needed to actually run the compiled gems)
RUN apk update && apk add --no-cache libxml2 libxslt libstdc++

# 2. Copy the gems from the builder
COPY --from=build-env $BUNDLE_PATH $BUNDLE_PATH

# 3. Ensure the lockfile generated in build-env is the one we use
COPY --from=build-env $APP_ROOT/Gemfile.lock ./Gemfile.lock

# 4. Copy the application code
COPY . .

# 5. Tell Bundler specifically to use the global path and ignore local configs
RUN bundle config set --local path $BUNDLE_PATH && \
    bundle config set --local without 'development test'

CMD ["bundle", "exec", "puma"]

LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="SamlProxy"
LABEL org.opencontainers.image.created="$BUILD_DATE"
LABEL org.opencontainers.image.source="$SOURCE"
LABEL org.opencontainers.image.revision="$REVISION"
