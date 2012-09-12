
$:.unshift(File.expand_path('../../lib', __FILE__))

require 'leg'


class Leg::Parser::CompositeParser

  attr_reader :children
end

class Leg::Parser::NonTerminalParser

  attr_reader :child
end


RSpec.configure do |config|
end

