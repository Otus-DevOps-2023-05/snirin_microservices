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

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
