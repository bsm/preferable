class Preferable::Field
  TYPES = [:string, :integer, :float, :boolean, :date, :datetime, :array].to_set.freeze
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set.freeze

  attr_reader :name, :type, :options, :default

  # Create a new Field.
  #
  # Params:
  #   name: The name symbol
  #   type: The type symbol, see Preferable::Field::TYPES
  #   options: The options hash (keys as symbols)
  #
  # Options:
  #   default: The default value.
  #   if:      Value assignment proc. Value is only assigned if true is yielded.
  #   unless:  Value assignment proc. Value is only assigned if false is yielded.
  #   cast:    Only relevant for :array type. Specify the type of the array contents.
  #
  # Examples:
  #   Field.new :color, :string, :if => lambda {|v| v =~ /^[A-F0-9]{6}$/ }
  #   Field.new :holidays, :array, :cast => :date
  #   Field.new :newsletter, :boolean, :default => false
  #   Field.new :age, :integer, :unless => &:zero?
  #
  def initialize(name, type, options = {})
    raise ArgumentError, "Unknown type '#{type}', available types are: #{TYPES.map(&:to_s).join(', ')}" unless TYPES.include?(type.to_sym)

    @name    = name.to_sym
    @type    = type.to_sym
    @options = options.dup
    @default = type_cast @options.delete(:default)
  end

  # Returns true if a value is assignable, else false. Assumes given value is already type-casted.
  def valid?(value)
    result = true
    result = options[:if].call(value) if result && options[:if]
    result = !options[:unless].call(value) if result && options[:unless]
    result
  end

  # Opposite of #valid?
  def invalid?(value)
    !valid?(value)
  end

  # Is value equal to the default. . Assumes given value is already type-casted.
  def default?(value)
    value == default
  end

  # Converts a value.
  def type_cast(value, to = self.type)
    return nil unless value

    case to
    when :string
      value.to_s
    when :integer
      value.to_i
    when :boolean
      TRUE_VALUES.include?(value)
    when :datetime
      to_time(value)
    when :date
      to_time(value).try(:to_date)
    when :float
      value.to_f
    when :array
      Array.wrap(value).tap do |wrap|
        wrap.map! {|item| type_cast(item, options[:cast]) } if options[:cast]
      end
    else
      value
    end
  end

  private

    def to_time(value)
      case value
      when Time
        value.in_time_zone
      when Date
        value.beginning_of_day
      else
        Time.zone.parse(value) rescue nil
      end
    end

end