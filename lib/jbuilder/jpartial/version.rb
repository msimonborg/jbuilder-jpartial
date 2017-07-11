begin
  require 'jbuilder/jbuilder'
rescue LoadError => e
  puts e.message
end

class Jbuilder
  module Jpartial
    VERSION = '1.0.1'.freeze
  end
end
