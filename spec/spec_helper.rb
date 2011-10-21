ENV["RAILS_ENV"] ||= 'test'

$: << File.dirname(__FILE__) + '/../lib'
require 'rubygems'
require 'bundler/setup'
Bundler.require :default, :test

require 'active_support'
require 'active_record'
require 'rspec'
require 'preferable'

Time.zone = 'UTC'
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.configurations["test"] = { 'adapter' => 'sqlite3', 'database' => ":memory:" }
ActiveRecord::Base.establish_connection(:test)
ActiveRecord::Base.connection.create_table :users do |t|
  t.string :name
  t.text   :preferences
end

class User < ActiveRecord::Base

  preferable do
    string  :color, :default => '444444'
    boolean :newsletter, :default => false
  end

end

class Admin < User

  preferable do
    boolean :reminder, :default => false
  end

end
