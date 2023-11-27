FROM alpine:3.5

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
COPY . $APP_HOME

RUN apk add --update \
    curl wget bash nano \
    ruby ruby-bundler \
    ca-certificates libressl \
    libressl-dev build-base ruby-dev \
    ruby-rdoc ruby-io-console ruby-irb \
    # install
    && bundle install \
    # remove packages
    && apk del  \
    ca-certificates libressl \
    libressl-dev build-base ruby-dev \
    ruby-io-console ruby-irb

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
