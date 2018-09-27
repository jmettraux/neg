
require 'pp'

$:.unshift(File.expand_path('../../lib', __FILE__))

require 'neg'


class Neg::Parser::SubParser

  attr_reader :children
end


RSpec.configure do |config|

  config.expect_with(:rspec) { |c| c.syntax = :should }
end

