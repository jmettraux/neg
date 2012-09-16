
$:.unshift(File.expand_path('../../lib', __FILE__))

require 'neg'


class Neg::Parser::CompositeParser

  attr_reader :children
end

class Neg::Parser::NonTerminalParser

  attr_reader :child
end


#RSpec.configure do |config|
#end

