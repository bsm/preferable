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

SPEC_DATABASE     = File.dirname(__FILE__) + '/tmp/test.sqlite3'
Time.zone_default = Time.__send__(:get_zone, "UTC")
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.configurations["test"] = { 'adapter' => 'sqlite3', 'database' => SPEC_DATABASE }

RSpec.configure do |c|
  c.before(:all) do
    FileUtils.mkdir_p File.dirname(SPEC_DATABASE)
    base = ActiveRecord::Base
    base.establish_connection(:test)
    base.connection.create_table :users do |t|
      t.string :name
      t.text   :preferences
    end
  end

  c.after(:all) do
    FileUtils.rm_f(SPEC_DATABASE)
  end
end

class User < ActiveRecord::Base

  preferable do
    string  :color, :default => '444444'
    boolean :newsletter, :default => false
  end

end
