require 'jbuilder'

require 'jbuilder/jpartial/version'

# Top level Jbuilder class
class Jbuilder
  def json
    self
  end

  alias_method :old_method_missing, :method_missing

  def method_missing(method_name, *args, &block)
    if method_name.to_s =~ /(.*)_(url|path)/ && defined? @context
      @context.send(method_name, *args, &block)
    else
      old_method_missing(method_name, *args, &block)
    end
  end

  # Jpartial module
  module Jpartial
    DangerousMethodName = Class.new(ArgumentError)

    def self.jpartial(name, &block)
      Jbuilder.class_eval do
        if method_defined?(name) || private_method_defined?(name)
          raise DangerousMethodName, "The method `##{name}` is already defined by Jbuilder. "\
            'Please choose another name to define your partial'
        else
          define_method(name, &block)
        end
      end
    end
  end
end
