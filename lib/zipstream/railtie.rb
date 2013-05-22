# Adds zip rendering support to Rails
class Zipstream::Railtie < Rails::Railtie
  initializer "zipstream" do
    # Register Mime::ZIP
    unless Mime::Type.lookup "application/zip"
      Mime::Type.register "application/zip", :zip
    end

    # Mark our template handler as rendering zip files
    Zipstream::Railtie::Template.default_format = Mime::ZIP

    # Tell ActionView we can handle templates
    ActionView::Template.register_template_handler :zipstream, Zipstream::Railtie::Template
  end

  # Create a zipstream as a rails template
  class Template
    class_attribute :default_format

    def self.call template
      "Zipstream::Body.new do |zip|
        #{template.source}
      end"
    end
  end
end
