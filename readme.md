Google Groups holds your message data hostage.
Here's a way to reclaim it.

# Approach

Page-scraping with Firefox, driven by Selenium-Webdriver and the wonderful Capybara DSL.

Authentication is not automated: switch to the browser window and authenticate by hand. This greatly simplifies things.

# Performance

It's not fast. Google Groups seems like the bottleneck.

# Usage

Insert your group's index url into scrape.example.rb or create your own script
based on it.
