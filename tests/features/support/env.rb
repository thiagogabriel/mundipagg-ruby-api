begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
$:.unshift(File.dirname(__FILE__) + '/../../../lib') 
require 'mundipagg'
require 'mundipagg/post_notification'
require_relative '../../test_helper.rb'
require_relative '../../test_config.rb'
