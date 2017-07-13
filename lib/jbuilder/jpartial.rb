require 'jbuilder'
require 'jbuilder/jpartial/version'

# Top level Jbuilder class
class Jbuilder
  # Jpartial module
  module Jpartial
    DangerousMethodName = Class.new(ArgumentError)

    @defined_by_user = []

    def self.jpartial(name, &block)
      _raise_dangerous_method_name_error(name) if _dangerous_method_name?(name)
      JbuilderProxy.class_eval { define_method(name, &block) }
      Jbuilder.class_eval do
        define_method(name) do |*args|
          JbuilderProxy.new(self, @context).__send__(name, *args)
        end
      end
      @defined_by_user << name unless @defined_by_user.include?(name)
    end

    def self._raise_dangerous_method_name_error(name)
      raise DangerousMethodName, "The method `##{name}` is already defined"\
        ' by Jbuilder. Please choose another name to define your partial'
    end

    def self._dangerous_method_name?(name)
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

    # Partial method execution is defined here. Jbuilder only knows how to
    # initialize an instance of the proxy class and send it the right message.
    # The proxy is initialized with the execution context if there is any
    # so it can pass along context methods when they're defined.
    class JbuilderProxy
      instance_methods.each do |meth|
        next if [:method_missing, :__send__, :object_id].include?(meth)
        undef_method(meth)
      end

      attr_reader :json

      def initialize(json, context = nil)
        @json    = json
        @context = context
      end

      def method_missing(method_name, *args, &block)
        if _method_defined_in_context?(method_name)
          @context.send(method_name, *args, &block)
        else
          super(method_name, *args, &block)
        end
      end

      def _method_defined_in_context?(method_name)
        !@context.nil? && @context.respond_to?(method_name)
      end
    end
  end
end

require 'jbuilder/jpartial/railtie' if defined?(Rails)
