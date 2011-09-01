ENV["RAILS_ENV"] ||= 'test'

$: << File.dirname(__FILE__) + '/../lib'
require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require :default, :test

require 'active_support'
require 'active_record'
require 'rspec'
require 'preferable'

ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.configurations["test"] = { 'adapter' => 'sqlite3', 'database' => ":memory:" }
Time.zone = 'UTC'

RSpec.configure do |c|
  c.before(:all) do
    base = ActiveRecord::Base
    base.establish_connection(:test)
    base.connection.create_table :users do |t|
      t.string :name
      t.text   :preferences
    end
  end
end

class User < ActiveRecord::Base

  preferable do
    string  :color, :default => '444444'
    boolean :newsletter, :default => false
  end

end
