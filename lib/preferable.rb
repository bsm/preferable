require "active_support/core_ext"
require "active_record"

module Preferable
  autoload :Model,  "preferable/model"
  autoload :Coder,  "preferable/coder"
  autoload :Schema, "preferable/schema"
  autoload :Field,  "preferable/field"
  autoload :Set,    "preferable/set"
end

ActiveRecord::Base.class_eval do
  include ::Preferable::Model
end
