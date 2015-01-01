# requires user to log in manually in the firefox window it spawns

require 'capybara'
require 'pry'
require './gag_scrape.rb'

Capybara.current_driver = :selenium
Capybara.app_host = 'https://groups.google.com'
Capybara.run_server = false

# log in, load all threads, scrape out the text
scraper = GagScrape.new 'https://groups.google.com/a/your.domain/forum/#!forum/your-forum'
scraper.log_in # this will block while you log in manually
scraper.load_all_threads # pagedown through infinite scroll
scraper.open_first_thread # get a thread on screen
scraper.print_thread_emails # scrape
while scraper.next_thread?
  scraper.next_thread # navigate by clicking > button
  scraper.print_thread_emails
end

binding.pry # visually check really at the end
