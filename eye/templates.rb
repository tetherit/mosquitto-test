class Namespace
  def initialize(hash)
    hash.each do |key, value|
      singleton_class.send(:define_method, key) { value }
    end
  end

  def get_binding
    binding
  end
end

def render_template(name, output, variables={})
  namespace = Namespace.new(variables)

  base_path = File.expand_path("../", __dir__)
  template_path = File.join(base_path, "templates/#{name}.erb")
  output_path = File.join(base_path, "tmp/etc/#{output}")

  renderer = ERB.new File.read(template_path)
  result = renderer.result(namespace.get_binding)
  File.open(output_path, 'w') do |f|
    f.write(result)
  end
end
