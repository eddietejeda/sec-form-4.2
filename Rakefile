# Rakefile
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./bootup"
  end
end


APP_FILE  = 'app.rb'
APP_CLASS = 'Sinatra::Application'

require 'sinatra/export/rake'