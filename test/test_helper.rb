ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "selenium/webdriver"

# Register a Docker-friendly Chrome driver
Capybara.register_driver :docker_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  # Use the Debian Chromium binary
  options.binary = "/usr/bin/chromium"
  # Required flags for headless Chrome in Docker
  %w[
    --headless
    --no-sandbox
    --disable-dev-shm-usage
    --disable-gpu
    --remote-debugging-port=9222
  ].each { |arg| options.add_argument(arg) }

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

# Make it the default JavaScript driver
Capybara.javascript_driver = :docker_chrome

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests
  fixtures :all
end