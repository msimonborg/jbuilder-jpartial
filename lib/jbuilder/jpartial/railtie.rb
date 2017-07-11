# frozen_string_literal: true

require 'rails/railtie'
require 'jbuilder/jbuilder_template'
require 'jbuilder/jpartial'

class Jbuilder
  module Jpartial
    # Adds the #json and #jpartial methods to .jbuilder templates
    class JpartialHandler < ::JbuilderHandler
      def self.call(template)
        %{__already_defined = defined?(json); json||=JbuilderTemplate.new(self);
          jpartial||=Jbuilder::Jpartial::Template.new;
          #{template.source}; json.target! unless
          (__already_defined && __already_defined != "method")}
      end
    end

    # Loads the template handler, overriding the JbuilderTemplate
    class Railtie < ::Rails::Railtie
      initializer :jpartial do
        ActiveSupport.on_load :action_view do
          ActionView::Template.register_template_handler :jbuilder,
                                                         JpartialHandler
        end
      end
    end
  end
end
