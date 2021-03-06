ENV['RACK_ENV'] = 'test'

require 'capybara/rspec'
require 'simplecov'
require 'simplecov-console'
require 'capybara'
require 'pry'
require 'rspec'
require 'database_cleaner'
require_relative '../models/price_updater'
require_relative '../models/version_updater'
require_relative '../models/totals'
require_relative './helpers'
require_relative '../app'
require_relative '../data_mapper_setup'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

Capybara.app = FactorySettingsElemental

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::Console,
  # Want a nice code coverage website? Uncomment this next line!
  # SimpleCov::Formatter::HTMLFormatter
])
SimpleCov.start
