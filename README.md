# ZaradotcomScraper

`zaradotcom-scraper` is a javascript-generated web scraper for [ZARA](http://www.zara.com/).

## Setup

This section describes the steps to setup on local machine.
Please make sure [PhantomJS](http://phantomjs.org/download.html) and [Redis](http://redis.io/) are already installed properly.

### Clone and setup locally

```bash
# Clone the repo
git clone https://github.com/hasaniskandar/zaradotcom-scraper.git

# Go to the app root directory
cd zaradotcom-scraper

# If you are using RVM
rvm 2.1.0@zaradotcom-scraper --create --ruby-version

# Install gems
bundle install

# Setup the database
bundle exec rake db:setup
```

### Start the app

```bash
bundle exec rails server
```

### Start the worker

```bash
QUEUE=* bundle exec rake environment resque:work
```

## Getting Started

- Go to [localhost:3000](http://localhost:3000/).
- Click **[New scrape](http://localhost:3000/jobs/new)** to start new scraper and wait until it is done *(Note that it may take several hours, depends on internet connection and resources)*.
- When it is done, download links will be visible.

## Heroku Setup

This section describes the required steps to setup to [Heroku](https://www.heroku.com/) on a free plan and unverified account.

### Setup web app

Create an app on **Cedar** stack with [heroku-buildpack-multi](https://github.com/ddollar/heroku-buildpack-multi):

```bash
heroku apps:create zaradotcom-scraper --stack cedar \
                                      --buildpack https://github.com/ddollar/heroku-buildpack-multi.git
```

Set `REDIS_URL` manually to use [Redis](http://redis.io/) without an [add-on](https://addons.heroku.com/?q=redis):

```bash
# Replace the url below with the correct one:
heroku config:set REDIS_URL="redis://my-username:my-password@my-redis.host:9999/" --app zaradotcom-scraper
```

Deploy:

```bash
# Push to Heroku
git push heroku master

# Compile assets and migrate the database
heroku run rake assets:precompile db:migrate --app zaradotcom-scraper
```

Scale 1 **web** dyno:

```bash
heroku ps:scale web=1 --app zaradotcom-scraper
```

### Setup worker app

Create another app with the same stack and buildpack as the first one, and also set its remote:

```bash
heroku apps:create zaradotcom-scraper-worker --stack cedar \
                                             --buildpack https://github.com/ddollar/heroku-buildpack-multi.git \
                                             --remote heroku-worker
```

Set `DATABASE_URL` and `REDIS_URL` exactly the same with web app:

```bash
heroku config:set DATABASE_URL="`heroku config:get DATABASE_URL --app zaradotcom-scraper`" \
                  REDIS_URL="`heroku config:get REDIS_URL --app zaradotcom-scraper`" \
                  --app zaradotcom-scraper-worker
```

Set `LD_LIBRARY_PATH` and `PATH` to make [heroku-buildpack-phantomjs](https://github.com/stomita/heroku-buildpack-phantomjs) works with [heroku-buildpack-multi](https://github.com/ddollar/heroku-buildpack-multi):

```bash
heroku config:set PATH="/usr/local/bin:/usr/bin:/bin:/app/vendor/phantomjs/bin" \
                  LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/lib:/app/vendor/phantomjs/lib" \
                  --app zaradotcom-scraper-worker
```

Deploy:

```bash
# Push to Heroku
git push heroku-worker master

# Compile assets and migrate the database
heroku run rake assets:precompile db:migrate --app zaradotcom-scraper-worker
```

Scale 1 **worker** dyno:

```bash
heroku ps:scale worker=1 --app zaradotcom-scraper-worker
```

Optionally, email notification can be enabled to monitor scraper.
Notification will be sent to subscriber(s) whenever scraper is *done* or *error*.

```bash
# EMAIL_SUBSCRIBERS      => Coma separated email addresses to receive notifications
# ACTION_MAILER_URL_HOST => Host name of the web app
# SMTP_USERNAME          => Email for SMTP setting
# SMTP_PASSWORD          => Password for SMTP setting
heroku config:set EMAIL_SUBSCRIBERS="first@subscriber.com, second@subscriber.com" \
                  ACTION_MAILER_URL_HOST="zaradotcom-scraper.herokuapp.com" \
                  SMTP_USERNAME="my@email.com" \
                  SMTP_PASSWORD="my-password" \
                  --app zaradotcom-scraper-worker
```


## Known Issues

* **[Error R14 (Memory quota exceeded)](https://devcenter.heroku.com/articles/error-codes#r14-memory-quota-exceeded):** `phantomjs` increases memory usage each time page is loaded until it exceeds quota limit.

