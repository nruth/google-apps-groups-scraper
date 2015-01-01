require 'pry'
require 'capybara'
require 'capybara/dsl'

# configure capybara for remote work
Capybara.current_driver = :selenium
Capybara.app_host = 'https://groups.google.com'
Capybara.run_server = false

# Scrapes email text from google apps groups threads
# url: google group forum root, e.g. 'https://groups.google.com/a/company.com/forum/#!forum/feedback'
class GagScrape
  include Capybara::DSL
  attr_accessor :email_count
  attr_accessor :url
  def initialize(url)
    self.url = url
    self.email_count = 0
  end

  def log_in
    visit url
    # Log-in to Google manually in the Firefox window, then halt pry
    binding.pry
  end

  def open_first_thread
    find('#options_menu').click
    find('div.gux-combo-item', text: 'Compact list view').click
    first('div.GJHURADCSD').click
    wait_until_loaded
  end

  def switch_to_chronological_view
    # switch to chronological view of thread
    find('#options_menu').click
    find('div.gux-combo-item', text: 'Chronological view').click
    # check new view is loaded
    # wait for popup to close
    has_no_css?('div.popupContent')
    # wait for page-change widget to be gone
    has_no_css?('div#t-h div.jfk-button-standard', text: 'Page')
  end

  def expand_all_emails
    find('#options_menu').click
    # single mail threads, and expanded threads, will not show expand option
    return if has_css?('div.gux-combo-item', text: 'Collapse all')
    find('div.gux-combo-item', text: 'Expand all').click
    has_no_css?('div.GJHURADKJB.GJHURADEFC.GJHURADJJB')
  end

  # assuming a thread is on the screen capture each email displayed
  def scrape_email_texts
    switch_to_chronological_view
    expand_all_emails
    all('div#tm-tl div.GJHURADDJB').map(&:text)
  end

  # await message loading
  def wait_until_loaded
    has_no_css?('div[role="alert"]', text: 'Loading')
  end

  def print_thread_emails
    scrape_email_texts.each do |email|
      File.write("email-#{email_count}.txt", email)
      puts "\n#EMAIL #{email_count} written"
      self.email_count += 1
    end
  end

  # click the > to go to the next thread
  def next_thread
    find(next_thread_css).click
    wait_until_loaded
  end

  def next_thread?
    has_css?(next_thread_css)
  end

  def total_threads
    threads_match[:total].to_i
  end

  def threads_loaded
    threads_match[:loaded].to_i
  end

  def unloaded_threads?
    has_css?('#f-h', text: /\d+ of many topics/) || threads_loaded < total_threads
  end

  def load_threads
    fail 'wrong page' unless
    current_url == url
    wait_until_loaded
    3.times { pagedown }
    has_no_css? '#f-h', text: 'Loading more topics'
  end

  def load_all_threads
    load_threads while unloaded_threads?
  end

  private

  # navigate / scroll page down by keypress
  def pagedown
    page.driver.browser
    .execute_script('return document.body')
    .send_keys(:page_down)
  end

  # return regex match on threads loaded and total
  def threads_match
    threads_text = find('#f-h', text: /\d+ of \d+ topics/).text
    threads_text.match(/(?<loaded>\d+) of (?<total>\d+) topics/)
  end

  def next_thread_css
    'div[aria-label^="Next"]'
  end

  def ensure_on(path)
    visit(path) unless current_url == path
  end
end
