# encoding: utf-8

# Set up environment
require 'sinatra'
require "sinatra/base"
require "sinatra/cookies"
require "sinatra/activerecord"

require 'pg'

# Curl settings
require 'curb'

# Logger settings
require 'logger'
logger = Logger.new(STDOUT)
logger.level = Logger::INFO

## Development only
if settings.development?
  require 'sinatra/reloader' 
  require "byebug" 
  require "awesome_print" 
  logger.level = Logger::DEBUG
end


# Get ready to load app
Dir["./models/*.rb", "./lib/**/*.rb"].each do |file| 
  require file
end

require './app'