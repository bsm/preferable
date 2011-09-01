# Includable module, for ActiveRecord::Base
module Preferable::Model
  extend ActiveSupport::Concern

  included do
    class_attribute :_preferable
  end

  module ClassMethods

    # Preferable definition for a model. Example:
    #
    #   class User < ActiveRecord::Base
    #
    #     preferable do
    #       integer :theme_id
    #       boolean :accessible, :default => false
    #       string  :font_color, :default => "444444", :if => lambda {|value| value =~ /^[A-F0-9]{6}$/ }
    #     end
    #
    #   end
    #
    def preferable(&block)
      unless _preferable
        self._preferable = Preferable::Schema.new
        serialize :preferences
        include PreferableMethods
      end
      self._preferable.instance_eval(&block) if block
      self._preferable
    end

  end

  module PreferableMethods

    # Accessor to preferences. Examples:
    #
    #   user = User.find(1)
    #   user.preferences[:theme_id] # => 8
    #   user.preferences[:theme_id] = 3
    #
    def preferences
      value = read_attribute(:preferences)
      value.is_a?(Preferable::Set) ? value : write_attribute(:preferences, Preferable::Set.new(self.class.name))
    end

    # Preferences writer. Updates existing preferences (doesn't replace them!)
    def preferences=(hash)
      preferences.set(hash) if hash.is_a?(Hash)
      preferences
    end

  end
end