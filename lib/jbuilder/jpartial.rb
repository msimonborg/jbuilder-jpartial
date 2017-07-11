require 'jbuilder'

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

    @defined_by_user = []

    def self.jpartial(name, &block)
      if dangerous_method_name?(name)
        raise DangerousMethodName, "The method `##{name}` is already defined"\
          ' by Jbuilder. Please choose another name to define your partial'
      else
        Jbuilder.class_eval do
          define_method(name, &block)
        end
        @defined_by_user << name unless @defined_by_user.include?(name)
      end
    end

    def self.dangerous_method_name?(name)
      !@defined_by_user.include?(name) &&
        Jbuilder.method_defined?(name) ||
        Jbuilder.private_method_defined?(name)
    end

    def self.configure(&block)
      module_eval(&block)
    end

    # Sends all method calls to Jpartial.jpartial for definition
    class Template
      def method_missing(method_name, &block)
        Jpartial.jpartial(method_name, &block)
      end
    end
  end
end

require 'jbuilder/jpartial/railtie' if defined?(Rails)
