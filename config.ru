# This file is used by Rack-based servers to start the application.
require "rack/attack"
require_relative "config/environment"

# This will allow us to use Rack::Attack for rate limiting
use Rack::Attack

run Rails.application
Rails.application.load_server
