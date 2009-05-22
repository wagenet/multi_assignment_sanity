$LOAD_PATH << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'

# Use an earlier version of Rails where date still fails since this makes our testing easier
gem 'activerecord', '<= 2.0.2'

require 'active_record'
require File.dirname(__FILE__) + '/../init'

class MultiAssignmentModel < ActiveRecord::Base
  # So we don't require an actual table
  def self.columns
    [ActiveRecord::ConnectionAdapters::Column.new('date', nil, 'date')]
  end

  sanitize_multi_assignment_errors
end

class MultiAssignmentSanityTest < Test::Unit::TestCase

  def test_sanitize_multi_assignment_errors
    obj = MultiAssignmentModel.new("date(1i)" => "2009", "date(2i)" => "6", "date(3i)" => "31")
    assert !obj.valid?
    assert_equal "has error: invalid date", obj.errors.on(:date)
  end

end
