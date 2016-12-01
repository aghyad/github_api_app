require 'rails_helper'
require 'github_api_handler'

RSpec.describe GithubApiHandler do
  let(:u) { FactoryGirl.create(:user) }
  let(:options) {
    {
      q: 'something',
      sort: 'stars',
      order: 'desc',
      per_page: '30',
      page: '1',
      user: u
    }
  }

  describe "#initialize" do
    it "should set the options and data_key vars to the correct values" do
      res = GithubApiHandler.new(options)
      expect(res.options).to eq(
        {
          :query=>{
            :q=>"something",
            :sort=>"stars",
            :order=>:desc,
            :per_page=>"30",
            :page=>"1"
          },
          :headers=>{
            "Authorization"=>"Token 45734secretrthyer3475347",
            "User-Agent"=>"github_api_app"
          }
        }
      )
      expect(res.data_key).to eq("#{u.email}_search_repos_something_30_1_stars_desc")
    end
  end

  describe "#search_repos" do
    let(:handler) { GithubApiHandler.new(options) }

    it "should return a reponse that always has 'ok' status" do
      res = handler.search_repos
      expect(res['ok']).to_not be_nil
    end

    it "should check the data_key in Redis first" do
      expect(RedisStore).to receive(:get).with(handler.data_key).once
      handler.search_repos
    end

    context "when redis get-call hits" do
      before do
        allow(RedisStore).to receive(:get).and_return([1,2,3])
      end

      it "should return the cached data from redis" do
        res = handler.search_repos
        expect(res).to eq([1,2,3])
      end
    end

    context "when redis get-call misses" do
      before do
        allow(RedisStore).to receive(:get).and_return(nil)
        allow(GithubApiHandler).to receive(:get).and_return(nil)
      end

      it "should call the remote github service on '/search/repositories'" do
        expect(GithubApiHandler).to receive(:get).with('/search/repositories', handler.options).once
        handler.search_repos
      end

      context "when the api call returns nil" do
        before do
          allow(GithubApiHandler).to receive(:get).and_return(nil)
        end

        it "should call the remote github service on '/search/repositories'" do
          res = handler.search_repos
          expect(res).to eq(
            {
              'ok'=> false,
              'message'=> "Error while connecting and searching GitHub API: No response when requesting from GitHub API '/search/repositories'",
              'data'=> {}
            }
          )
        end

        it "should not cache any value in redis" do
          expect(RedisStore).to receive(:set).exactly(0).times
          handler.search_repos
        end
      end

      context "when the api call returns anything but nil" do
        context "when that returned value is an error" do
          before do
            d = double
            allow(d).to receive(:parsed_response).and_return({'message'=> 'some-error-message'})
            allow(GithubApiHandler).to receive(:get).and_return(d)
          end

          it "should call the remote github service on '/search/repositories'" do
            res = handler.search_repos
            expect(res).to eq(
              {
                "ok"=>false,
                "message"=>"Error while connecting and searching GitHub API: \"some-error-message\"",
                "data"=>{}
              }
            )
          end

          it "should not cache any value in redis" do
            expect(RedisStore).to receive(:set).exactly(0).times
            handler.search_repos
          end
        end

        context "when that returned value is a data value with no errors" do
          before do
            d = double
            allow(d).to receive(:parsed_response).and_return('data-object-or-set')
            allow(GithubApiHandler).to receive(:get).and_return(d)
          end

          it "should call the remote github service on '/search/repositories'" do
            res = handler.search_repos
            expect(res).to eq(
              {
                "ok"=>true,
                "data"=> 'data-object-or-set'
              }
            )
          end

          it "should store the result value in redis" do
            res = {
              "ok"=>true,
              "data"=> 'data-object-or-set'
            }
            expect(RedisStore).to receive(:set).with(handler.data_key, res, 300).once
            handler.search_repos
          end
        end
      end
    end
  end
end
