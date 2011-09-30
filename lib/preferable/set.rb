class Preferable::Set < Hash
  PRIVATE   = [:rehash, :fetch, :store, :shift, :delete, :delete_if, :keep_if].to_set.freeze

  # Make destructive methods private
  (public_instance_methods - Hash.superclass.public_instance_methods).each do |m|
    PRIVATE.include?(m.to_sym) || m.to_s.ends_with?('!')
  end

  def self.wrap(owner, value)
    new(owner).set(value || {})
  end

  attr_reader :owner

  def initialize(owner)
    super()
    @owner = owner
  end

  def [](name)
    field = find_field(name)
    super(field.name) || field.default if field
  end

  def []=(name, value)
    field = find_field(name) || return
    value = field.type_cast(value)

    if value.nil? || field.invalid?(value) || field.default?(value)
      delete field.name
    else
      super field.name, value
    end
    owner.send :write_attribute, :preferences, to_hash
  end

  def set(pairs)
    pairs.each {|k, v| self[k] = v }
    self
  end

  def to_hash
    {}.update(self)
  end

  private

    def find_field(name)
      owner.class._preferable[name.to_s] if owner
    end

end