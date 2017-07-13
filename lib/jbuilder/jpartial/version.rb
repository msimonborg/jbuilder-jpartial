begin
  require 'jbuilder/jbuilder'
rescue LoadError => e
  puts e.message
end

class Jbuilder
  module Jpartial
    VERSION = '1.1.0'.freeze
  end
end
