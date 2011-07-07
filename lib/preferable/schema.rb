require 'set'

class Preferable::Schema < Hash

  def initialize
    super
  end

  def field(name, type, options = {})
    item = Preferable::Field.new(name, type, options)
    self[item.name] = item
  end

  Preferable::Field::TYPES.each do |sym|
    define_method sym do |name, options|
      field name, sym, options
    end
  end

end