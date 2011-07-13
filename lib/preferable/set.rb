class Preferable::Set < Hash
  MODEL_KEY = "_".freeze
  PRIVATE   = [:rehash, :fetch, :store, :shift, :delete, :delete_if, :keep_if].to_set.freeze

  # Make destructive methods private
  (public_instance_methods - Hash.superclass.public_instance_methods).each do |m|
    PRIVATE.include?(m.to_sym) || m.to_s.ends_with?('!')
  end

  def initialize(model_name)
    super()
    store MODEL_KEY, "::#{model_name}"
  end

  def model
    @model ||= fetch(MODEL_KEY).constantize
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
  end

  def set(pairs)
    pairs.each {|k, v| self[k] = v }
    self
  end

  private

    def find_field(name)
      model.preferable[name.to_sym]
    end

end