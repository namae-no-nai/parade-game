FROM ruby:3.1.3

WORKDIR /app

COPY . /app/

RUN bundle install

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
