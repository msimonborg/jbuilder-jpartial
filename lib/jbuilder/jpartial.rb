require 'jbuilder'

# Top level Jbuilder class
class Jbuilder
  def json
    self
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

    def self.configure
      yield Template.new
    end

    # Proxy object that sends all method calls to Jpartial.jpartial
    Template = Class.new(begin
                           require 'active_support/proxy_object'
                           ActiveSupport::ProxyObject
                         rescue LoadError
                           require 'active_support/basic_object'
                           ActiveSupport::BasicObject
                         end) do

      def method_missing(name, *args, &block)
        name = name.to_s == 'send' ? args.first.to_sym : name
        Jpartial.jpartial(name, &block)
      end
    end
  end
end

require 'jbuilder/jpartial/railtie' if defined?(Rails)
