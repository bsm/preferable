class Preferable::Set < Hash
  yaml_tag "tag:ruby.yaml.org,2002:hash"
  yaml_tag "tag:yaml.org,2002:map"

  PRIVATE   = [:rehash, :fetch, :store, :shift, :delete, :delete_if, :keep_if].to_set.freeze

  # Make destructive methods private
  (public_instance_methods - Hash.superclass.public_instance_methods).each do |m|
    PRIVATE.include?(m.to_sym) || m.to_s.ends_with?('!')
  end

  def self.wrap(owner, value)
    if value.instance_of?(self) && value.owner == owner
      value
    elsif value.is_a?(String) && value.include?('!map:Preferable::Set ')
      wrap owner, YAML.load(value.sub(':Preferable::Set ', ''))
    else
      new(owner).update(value || {})
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

  def to_yaml(*a)
    to_hash.to_yaml(*a)
  end

  def init_with(coder)
    update coder.map.symbolize_keys
  end

  def encode_with(coder)
    each {|k, v| coder[k.to_s] = v }
  end

  private

    def find_field(name)
      owner.class._preferable[name.to_sym] if owner
    end

end