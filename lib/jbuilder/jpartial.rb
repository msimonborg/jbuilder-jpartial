require 'jbuilder/jpartial/version'

# Top level Jbuilder class
class Jbuilder
  include Jpartial

  # Jpartial module
  module Jpartial
    Partials = Class.new

    def jpartial(*args, &block)
      if args && block_given?
        define_partial(args, &block)
      else
        Partials.new
      end
    end

    def define_partial(*args, &block)
      name = args.first

      Partials.define_method(name, &block)
    end
  end
end
