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
      serialize :preferences, Hash
      include PreferableMethods

      self._preferable   = self._preferable.dup if self._preferable
      self._preferable ||= Preferable::Schema.new
      self._preferable.instance_eval(&block)
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
      result = super
      result.is_a?(Preferable::Set) ? result : write_attribute(:preferences, Preferable::Set.wrap(self, result))
    end

    # Preferences writer. Updates existing preferences (doesn't replace them!)
    def preferences=(hash)
      preferences.set(hash) if hash.is_a?(Hash)
      preferences
    end

  end
end