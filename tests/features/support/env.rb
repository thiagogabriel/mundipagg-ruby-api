begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
$:.unshift(File.dirname(__FILE__) + '/../../../lib') 
require 'mundipagg'
require 'bigdecimal'
require_relative '../../test_helper.rb'
require_relative '../../test_configuration.rb'
