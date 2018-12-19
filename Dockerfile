FROM alpine:3.7

RUN apk add --no-cache ruby ruby-json ruby-io-console nodejs \
 && apk add --no-cache ruby-dev build-base

RUN gem install --no-document smashing mqtt tzinfo-data

COPY . /data
WORKDIR /data

EXPOSE 3000

CMD ["thin", "start"]
