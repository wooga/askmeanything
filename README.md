Woogas' Ask Me Anything Application
====

Provides basic AmA functionality, it's *Raison d'être* is that google
shutdown their AmA tool, so we DIY'ed!

Deployment to Heroku
---

Application can be easily deployed to heroku using the button below.

[![Deploy To Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

You'll need to provide some configuration details, these are defined in the
[app.json](https://github.com/wooga/askmeanything/blob/master/app.json).

Running Locally
---

First use bundle to install all dependencies:

    gem install bundler
    bundle install

Generate a ```.env``` file from the heroku application specification file ```app.json```

    rake appjson:to_dotenv

Edit the generate ```.env``` file and add a DATABASE_URL value (for example):

    DATABASE_URL=postgres://dbuser:password@localhost:5432/wham

This value gets set automagically by Heroku, but locally it needs to be
defined by hand.

Initialize the database:

    rake db:migrate

fill it out and start application with

    foreman start

done.

Anonymity
---

The app requires the email of the user but this is stored in a per-round
hashed value in the database. I.e. a hashed email is unique per round and
ensures that everyone only votes once per question. 
But your oauth username will be attached to your question and will be visible for everyone.
