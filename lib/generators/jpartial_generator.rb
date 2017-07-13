# frozen_string_literal: true

require 'rails/generators'

module Jpartial
  module Generators
    # Generate a configuration template for partials.
    class JpartialGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_config_file
        template 'jpartial.rb.erb', 'config/initializers/jpartial.rb'
      end
    end
  end
end
