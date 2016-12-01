require 'rails_helper'
require 'github_api_handler'

RSpec.describe SearchesController, type: :controller do

  describe "GET #search" do
    before do
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
      # session[:user_id] = user.id
    end

    context "when user is NOT logged in" do
      let(:user) { nil }
      it "returns http success" do
        get :search
        expect(response).to redirect_to home_request_authentication_path
      end
    end

    context "when user is logged in" do
      let(:user) { FactoryGirl.create(:user) }

      it "will not redirect to login page" do
        get :search
        expect(response).to_not redirect_to home_request_authentication_path
      end

      context "when no searching parameters are passed" do
        it "returns http success" do
          get :search
          expect(response).to be_success
        end
      end

      context "when searching parameters are passed" do
        let(:search_params) {
          {
            q: 'something',
            page: '1',
            language: '',
            sort: '',
            order: ''
          }
        }

        before do
          allow(GithubApiHandler).to receive(:new)
          @search_obj = Search.new
          allow(Search).to receive(:new).and_return(@search_obj)
          @search_obj.stub(:perform)
        end

        it "creates all instance vars and returns http success" do
          get :search, search_params

          expect(assigns(:search_keyword)).to eq(search_params[:q])
          expect(assigns(:page)).to eq(search_params[:page])
          expect(assigns(:language_filter)).to eq(search_params[:language])
          expect(assigns(:sort)).to eq(search_params[:sort])
          expect(assigns(:order)).to eq(search_params[:order])
          expect(assigns(:search_options).class).to eq(Hash)
          expect(response).to be_success
        end

        it "initializes an instance of the Search model" do
          expect(Search).to receive(:new)
          get :search, search_params
        end

        it "passes the perform method to an instance of the Search model" do
          expect(@search_obj).to receive(:perform)
          get :search, search_params
        end

        context "when the response of the search service fails" do
          before do
            allow(@search_obj).to receive(:response_error_message).and_return('some error')
          end

          it "should set the flash message to that error message" do
            get :search, search_params
            expect(flash[:alert]).to eq('some error')
          end
        end
      end
    end
  end
end
