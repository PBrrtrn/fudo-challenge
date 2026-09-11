ARG RUBY_VERSION=4.0.6

FROM ruby:${RUBY_VERSION}-slim AS base

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        libyaml-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app


# Install dependencies
FROM base as dependencies_install
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3


# Build application
FROM base as build_final
RUN groupadd --system app && useradd --system --gid app --create-home app

WORKDIR /app

COPY --from=dependencies_install /usr/local/bundle /usr/local/bundle
COPY --from=dependencies_install /app/Gemfile /app/Gemfile.lock ./

COPY config ./config
COPY src ./src
COPY config.ru ./

ENV RACK_END=production \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_WITHOUT=development:test \
    HOST=0.0.0.0 \
    PORT=3000

RUN chown -R app:app /app
USER app
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
