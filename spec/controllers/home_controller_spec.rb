require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #about" do
    it "returns http success" do
      get :about
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #request_authentication" do
    it "returns http success" do
      get :request_authentication
      expect(response).to have_http_status(:success)
    end
  end
end
