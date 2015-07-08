require 'test_helper'

class ProjectTimeSheetsControllerTest < ActionController::TestCase
  setup do
    @project_time_sheet = project_time_sheets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_time_sheets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_time_sheet" do
    assert_difference('ProjectTimeSheet.count') do
      post :create, project_time_sheet: { Description,: @project_time_sheet.Description,, Link: @project_time_sheet.Link, Title,: @project_time_sheet.Title, }
    end

    assert_redirected_to project_time_sheet_path(assigns(:project_time_sheet))
  end

  test "should show project_time_sheet" do
    get :show, id: @project_time_sheet
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project_time_sheet
    assert_response :success
  end

  test "should update project_time_sheet" do
    patch :update, id: @project_time_sheet, project_time_sheet: { Description,: @project_time_sheet.Description,, Link: @project_time_sheet.Link, Title,: @project_time_sheet.Title, }
    assert_redirected_to project_time_sheet_path(assigns(:project_time_sheet))
  end

  test "should destroy project_time_sheet" do
    assert_difference('ProjectTimeSheet.count', -1) do
      delete :destroy, id: @project_time_sheet
    end

    assert_redirected_to project_time_sheets_path
  end
end
