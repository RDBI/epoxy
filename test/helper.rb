require 'rubygems'
gem 'test-unit'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'epoxy'

class Test::Unit::TestCase
end

# vim: syntax=ruby ts=2 et sw=2 sts=2
