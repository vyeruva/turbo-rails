require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Use our custom Docker Chrome driver for system tests
  driven_by :docker_chrome, screen_size: [1400, 1400]
end