FROM alpine:3.8
RUN apk update && apk add ruby-full ruby-dev  build-base \
    && gem install bundler:1.17.2 --no-document && gem install bson_ext -v '1.12.5' --source 'https://rubygems.org/' \
    && gem install thrift -v '0.9.3.0' --source 'https://rubygems.org/' && gem install puma -v '3.12.0' --source 'https://rubygems.org/' \
    && apk del --no-cache ruby-dev build-base


ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
CMD ["puma"]