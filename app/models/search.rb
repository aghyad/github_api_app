class Search
  attr_reader :search_handler, :parsed_response,
              :response_data_items, :response_error_message

  def initialize(options = {})
    @search_handler = GithubApiHandler.new(options)
    @parsed_response = {}
    @response_data_items = []
    @response_error_message = nil
  end

  def perform
    @parsed_response = search_handler.search_repos
    if response_ok?
      @response_data_items = parsed_response['data']['items'] || []
    else
      @response_error_message = parsed_response['message']
    end
  end

  def response_ok?
    !!parsed_response['ok']
  end

  def by_language(language_filter)
    return [] unless response_ok?
    language_filter = '' if language_filter.downcase == 'all languages'
    return response_data_items unless language_filter.present?
    response_data_items.select {|x| x['language'] == language_filter }
  end

  def extract_language_filters
    return [''] unless response_ok?
    ['All Languages', response_data_items.map{|m| m['language']}.uniq.reject{|m| m.blank?}].flatten
  end
end
