require 'test_helper'

class IgramsControllerTest < ActionController::TestCase
  setup do
    @igram = igrams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:igrams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create igram" do
    assert_difference('Igram.count') do
      post :create, igram: { dateTime: @igram.dateTime, image_path: @igram.image_path, link: @igram.link, text: @igram.text, url: @igram.url }
    end

    assert_redirected_to igram_path(assigns(:igram))
  end

  test "should show igram" do
    get :show, id: @igram
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @igram
    assert_response :success
  end

  test "should update igram" do
    patch :update, id: @igram, igram: { dateTime: @igram.dateTime, image_path: @igram.image_path, link: @igram.link, text: @igram.text, url: @igram.url }
    assert_redirected_to igram_path(assigns(:igram))
  end

  test "should destroy igram" do
    assert_difference('Igram.count', -1) do
      delete :destroy, id: @igram
    end

    assert_redirected_to igrams_path
  end
end
