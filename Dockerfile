FROM ruby:2.7-buster
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install
COPY . /app
ENV PORT=9292
CMD bundle exec puma
