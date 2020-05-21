# frozen_string_literal: true

thread_count = ENV.fetch('PUMA_MAX_THREADS', 5)
threads     thread_count, thread_count
port        ENV.fetch('PORT', 9292)
environment ENV.fetch('RACK_ENV', 'development')
