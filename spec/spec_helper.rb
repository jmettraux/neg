
$:.unshift(File.expand_path('../../lib', __FILE__))

require 'leg'


class Leg::Parser::CompositeParser

  attr_reader :children
end


RSpec.configure do |config|
end

