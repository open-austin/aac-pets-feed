### About

This is a partner to the Pet Alerts website, and acts as a simple data source, using the Austin, TX 
Socrata data portal from [Austin Animal Center](https://data.austintexas.gov/Government/Austin-Animal-Center-Stray-Map/kz4x-q9k5).

### Install

  git clone git@github.com:tshelburne/aac-pets-feed.git
  bundle install --path=vendor

### Usage

Copy _api-config.rb.EXAMPLE_ to _api-config.rb_

The distributed configuration is appropriate for posting to localhost:3000 -- i.e. a local development instance of the Pet Alerts app.

For production use, adjust settings of the _api-config.rb_ file.

Run with:

  ruby scrape.rb

