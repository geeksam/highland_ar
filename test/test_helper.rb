require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'mocha'
require 'ruby-debug'

require File.join(File.dirname(__FILE__), *%w[.. lib highland_ar])

# I hear #send(:include, Foo) doesn't work in 1.9.
# Apparently they're a lot more strict in The Future.
class NotActuallyActiveRecordBase
  def self.pretty_please_include_this_module(the_module)
    include the_module
  end
  def self.has_one(association_name)
    define_method "#{association_name}=" do |obj|
      instance_variable_set("@#{association_name}", obj)
    end
    define_method association_name do
      instance_variable_get("@#{association_name}")
    end
  end
end

class HighlandARTestCase < ActiveSupport::TestCase
  def new_highlandar_class(*tcboo_methods)
    Class.new(NotActuallyActiveRecordBase).tap do |klass|
      klass.pretty_please_include_this_module(HighlandAR)
      tcboo_methods.each { |e| klass.there_can_be_only_one(e) }
    end
  end

  def deny(condition, *args)
    assert !condition, *args
  end
end
