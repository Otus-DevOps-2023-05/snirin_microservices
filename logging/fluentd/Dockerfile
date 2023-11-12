FROM fluent/fluentd:v1.16.2-1.0
RUN gem install fluent-plugin-elasticsearch  --user-install
RUN gem install fluent-plugin-grok-parser  --user-install
ADD fluent.conf /fluentd/etc
