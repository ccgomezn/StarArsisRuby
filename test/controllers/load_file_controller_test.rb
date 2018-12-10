require 'test_helper'

class LoadFileControllerTest < ActionDispatch::IntegrationTest
  test "should get loadFile" do
    get load_file_loadFile_url
    assert_response :success
  end

end
