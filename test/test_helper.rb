#$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/pride'
require 'mocha/mini_test'
require 'shoulda/context'
require 'enumerando'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(reporter_options)]
