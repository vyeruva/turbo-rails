require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Warden::Test::Helpers
  
  # Use our custom Docker Chrome driver for system tests
  driven_by :docker_chrome, screen_size: [1400, 1400]
end