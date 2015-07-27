require 'test_helper'

class AlohasControllerTest < ActionController::TestCase
  setup do
    @aloha = alohas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alohas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create aloha" do
    assert_difference('Aloha.count') do
      post :create, aloha: { name: @aloha.name }
    end

    assert_redirected_to aloha_path(assigns(:aloha))
  end

  test "should show aloha" do
    get :show, id: @aloha
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @aloha
    assert_response :success
  end

  test "should update aloha" do
    patch :update, id: @aloha, aloha: { name: @aloha.name }
    assert_redirected_to aloha_path(assigns(:aloha))
  end

  test "should destroy aloha" do
    assert_difference('Aloha.count', -1) do
      delete :destroy, id: @aloha
    end

    assert_redirected_to alohas_path
  end
end
