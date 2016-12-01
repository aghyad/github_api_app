require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the HomeHelper. For example:
#
# describe HomeHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SearchesHelper, type: :helper do
  let(:search_options) {
    {
      search_keyword: 'something',
      language_filter: 'Ruby',
      sort: 'stars',
      order: 'desc'
    }
  }

  describe "build_pagination_numeric_url" do
    it "should return the correct url" do
      expect(helper.build_pagination_numeric_url(search_options, 1)).to eq(
        "/search?q=something&page=1&language=Ruby&sort=stars&order=desc"
      )
    end
  end

  describe "stars_ordering_url" do
    it "return the correct stars header name and its url value" do
      expect(helper.stars_ordering_url(search_options).inspect).to eq(
        "[\"Stars<img src=\\\"icons/desc-order.png\\\" style=\\\"width:10px\\\"></img>\", \"/search?q=something&page=1&language=Ruby&sort=stars&order=asc\"]"
      )
    end
  end

  describe "build_stars_text_and_url" do
    context "when search_options is passed correctly" do
      it "should generate the correct stars' header url" do
        expect(helper.build_stars_text_and_url(search_options)).to eq(
          "<a href=\"/search?q=something&amp;page=1&amp;language=Ruby&amp;sort=stars&amp;order=asc\">Stars<img src=\"icons/desc-order.png\" style=\"width:10px\"></img></a>"
        )
      end
    end

    context "when search_options is blank?" do
      it "should return 'Stars'" do
        expect(helper.build_stars_text_and_url([])).to eq('Stars')
      end
    end
  end

  describe "build_numeric_pagination_urls" do
    it "should build the individual pagination numbers and their urls" do
      res = helper.build_numeric_pagination_urls(1..5, 1, search_options)
      expect(res.size).to eq(5)
      expect(res[0]).to eq(
        [1, "/search?q=something&page=1&language=Ruby&sort=stars&order=desc"]
      )
      expect(res[-1]).to eq(
        [5, "/search?q=something&page=5&language=Ruby&sort=stars&order=desc"]
      )
    end
  end
end
