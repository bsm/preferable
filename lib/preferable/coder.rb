class Preferable::Coder

  def dump(obj)
    ActiveSupport::JSON.encode(obj) if obj.is_a?(Hash) && obj.present?
  end

  def load(string)
    return {} if string.blank?
    return string if string.is_a?(Hash)
    return legacy_load(string) if string.is_a?(String) && string =~ /^---/

    begin
      obj = ActiveSupport::JSON.decode(string) || {}
      raise ActiveRecord::SerializationTypeMismatch, "Attribute was supposed to be a Hash, but was a #{obj.class}" unless obj.is_a?(Hash)
      obj
    rescue MultiJson::DecodeError
      {}
    end
  end

  private

    def legacy_load(yaml)
      lines = yaml.lines.to_a
      lines.shift
      YAML.load ["---", *lines].join("\n")
    end

end