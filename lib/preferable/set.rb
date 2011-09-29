class Preferable::Set < Hash
  PRIVATE   = [:rehash, :fetch, :store, :shift, :delete, :delete_if, :keep_if].to_set.freeze

  # Make destructive methods private
  (public_instance_methods - Hash.superclass.public_instance_methods).each do |m|
    PRIVATE.include?(m.to_sym) || m.to_s.ends_with?('!')
  end

  def self.wrap(owner, value)
    if value.instance_of?(self) && value.owner == owner
      value
    else
      value = {} unless value.is_a?(Hash)
      new(owner).update(value)
    end
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
      owner.changed_attributes["preferences"] = to_hash if key?(field.name)
      delete field.name
    else
      owner.changed_attributes["preferences"] = to_hash unless self[field.name] == value
      super field.name, value
    end
  end

  def set(pairs)
    pairs.each {|k, v| self[k] = v }
    self
  end

  def to_hash
    {}.update(self)
  end

  def to_yaml(*a)
    to_hash.to_yaml(*a)
  end

  private

    def find_field(name)
      owner.class._preferable[name.to_sym] if owner
    end

end