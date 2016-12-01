require 'rails_helper'
require 'github_api_handler'

RSpec.describe Search, type: :model do
  let(:options) { {} }

  before do
    @github_api_handler = double
    allow(GithubApiHandler).to receive(:new).and_return(@github_api_handler)
  end

  describe "#initialize" do
    it "should initialize all instance vars" do
      search_obj = Search.new(options)
      expect(search_obj.search_handler).to_not be_nil
      expect(search_obj.parsed_response).to_not be_nil
      expect(search_obj.response_data_items).to_not be_nil
      expect(search_obj.response_error_message).to be_nil
    end

    it "should send .new to the external service handler github_api_handler" do
      expect(GithubApiHandler).to receive(:new).once
      search_obj = Search.new(options)
    end
  end

  describe "#perform" do
    context "when the service response is successful" do
      before do
        github_api_handler = double
        allow(github_api_handler).to receive(:search_repos).and_return({'ok'=>true, 'data'=>{'items'=> [1,2,3]}})
        allow(GithubApiHandler).to receive(:new).and_return(github_api_handler)
        @search_obj = Search.new(options)
      end

      it "should set response_data_items to the data items set in the response" do
        @search_obj.perform
        expect(@search_obj.response_data_items).to eq([1,2,3])
        expect(@search_obj.response_error_message).to be_nil
      end
    end

    context "when the service response is fails" do
      before do
        github_api_handler = double
        allow(github_api_handler).to receive(:search_repos).and_return({'ok'=>false, 'message'=>'some-message'})
        allow(GithubApiHandler).to receive(:new).and_return(github_api_handler)
        @search_obj = Search.new(options)
      end

      it "should set response_data_items to the data items set in the response" do
        @search_obj.perform
        expect(@search_obj.response_error_message).to eq('some-message')
        expect(@search_obj.response_data_items).to eq([])
      end
    end
  end

  describe "#response_ok?" do
    context "when the service response is successful" do
      before do
        github_api_handler = double
        allow(github_api_handler).to receive(:search_repos).and_return({'ok'=>true, 'data'=>{'items'=> [1,2,3]}})
        allow(GithubApiHandler).to receive(:new).and_return(github_api_handler)
        @search_obj = Search.new(options)
      end

      it "should have response_ok? as truthy" do
        @search_obj.perform
        expect(@search_obj.response_ok?).to be true
      end
    end

    context "when the service response is fails" do
      before do
        github_api_handler = double
        allow(github_api_handler).to receive(:search_repos).and_return({'ok'=>false, 'message'=>'some-message'})
        allow(GithubApiHandler).to receive(:new).and_return(github_api_handler)
        @search_obj = Search.new(options)
      end

      it "should have response_ok? as false" do
        @search_obj.perform
        expect(@search_obj.response_ok?).to be false
      end
    end
  end

  describe "#by_language" do
    context "when the service response is fails" do
      before do
        github_api_handler = double
        allow(github_api_handler).to receive(:search_repos).and_return({'ok'=>false, 'message'=>'some-message'})
        allow(GithubApiHandler).to receive(:new).and_return(github_api_handler)
        @search_obj = Search.new(options)
      end

      it "should have by_language return an empty set of items" do
        @search_obj.perform
        expect(@search_obj.by_language('bluh')).to eq([])
      end
    end

    context "when the service response is successful" do
      let(:items) {
        [
          {'name'=> 'name1', 'language'=> 'Ruby', 'other_info'=> 'info'},
          {'name'=> 'name2', 'language'=> 'Javascript', 'other_info'=> 'info'},
          {'name'=> 'name3', 'language'=> 'Ruby', 'other_info'=> 'info'},
          {'name'=> 'name4', 'language'=> 'C++', 'other_info'=> 'info'},
          {'name'=> 'name5', 'language'=> 'C++', 'other_info'=> 'info'},
        ]
      }

      before do
        github_api_handler = double
        allow(github_api_handler).to receive(:search_repos).and_return({'ok'=>true, 'data'=>{'items'=> items}})
        allow(GithubApiHandler).to receive(:new).and_return(github_api_handler)
        @search_obj = Search.new(options)
      end

      context "when a language is provided correctly" do
        it "should have by_language return the set of items filtered by the provided language" do
          @search_obj.perform
          expect(@search_obj.by_language('Ruby')).to eq(
            [
              {'name'=> 'name1', 'language'=> 'Ruby', 'other_info'=> 'info'},
              {'name'=> 'name3', 'language'=> 'Ruby', 'other_info'=> 'info'}
            ]
          )
        end
      end

      context "when a language var is ''" do
        it "should have by_language return the original set of items without filtering" do
          @search_obj.perform
          expect(@search_obj.by_language('')).to eq(items)
        end
      end

      context "when a language var is 'All Languages'" do
        it "should have by_language return the original set of items without filtering" do
          @search_obj.perform
          expect(@search_obj.by_language('All Languages')).to eq(items)
        end
      end
    end
  end

  describe "#extract_language_filters" do
    context "when the service response is fails" do
      before do
        github_api_handler = double
        allow(github_api_handler).to receive(:search_repos).and_return({'ok'=>false, 'message'=>'some-message'})
        allow(GithubApiHandler).to receive(:new).and_return(github_api_handler)
        @search_obj = Search.new(options)
      end

      it "should have extract_language_filters return an empty set of languages" do
        @search_obj.perform
        expect(@search_obj.extract_language_filters).to eq([''])
      end
    end

    context "when the service response is successful" do
      let(:items) {
        [
          {'name'=> 'name1', 'language'=> 'Ruby', 'other_info'=> 'info'},
          {'name'=> 'name2', 'language'=> 'Javascript', 'other_info'=> 'info'},
          {'name'=> 'name3', 'language'=> 'Ruby', 'other_info'=> 'info'},
          {'name'=> 'name4', 'language'=> 'C++', 'other_info'=> 'info'},
          {'name'=> 'name5', 'language'=> 'C++', 'other_info'=> 'info'},
        ]
      }

      before do
        github_api_handler = double
        allow(github_api_handler).to receive(:search_repos).and_return({'ok'=>true, 'data'=>{'items'=> items}})
        allow(GithubApiHandler).to receive(:new).and_return(github_api_handler)
        @search_obj = Search.new(options)
      end

      it "should have extract_language_filters return the full set of languages without repetition" do
        @search_obj.perform
        expect(@search_obj.extract_language_filters).to eq(
          [
            "All Languages",
            "Ruby",
            "Javascript",
            "C++"
          ]
        )
      end
    end
  end
end
