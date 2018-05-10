require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test "should not save project without title and description" do
    num = Project.all.count
    assert_equal 2, num
  end


end
