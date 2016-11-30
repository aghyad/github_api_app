class SearchesController < ApplicationController
  before_action :authenticate_user!

  def search
    if search_requested?
      extract_or_init_search_request_params

      ### Search vars
      @search_keyword = query
      @page = params[:page]
      @language_filter = params[:language]
      @sort = params[:sort]
      @order = params[:order]

      @language_filters = nil
      @items = nil
      @error = nil

      ### Pagination vars (MOVE TO HELPER)
      @next_url = build_next_url(@search_keyword, @page, @language_filter, @sort, @order)
      @numeric_pagination_urls = [].tap do |arr|
        (1..10).each { |num| arr << [num, build_numeric_url(@search_keyword, num, @language_filter, @sort, @order)] }
      end
      @previous_url = build_previous_url(@search_keyword, @page, @language_filter, @sort, @order)

      ### Symbols for ordering by "stars" (MOVE TO HELPER)
      @stars_ordering_url = [
        (@order=='desc' ? 'Stars [Desc]' : 'Stars [Asc]'),
        build_numeric_url(@search_keyword, 1, @language_filter, @sort, (@order=='desc' ? 'asc' : 'desc'))
      ]

      ### now, we do the search:
      if search_query_present?
        handler = GithubApiHandler.new(@search_keyword, current_user.email, current_user.encrypted_password, :stars, @order.to_sym, per_page, @page)
        parsed_response = handler.search_repos

        if parsed_response['ok']
          parsed_response_items = parsed_response['data']['items'] || []
          @language_filters = extract_language_filters(parsed_response_items)
          @items = filter_language(parsed_response_items, @language_filter)
        else
          @error = parsed_response['message']
          flash[:alert] = @error
          redirect_to home_request_authentication_path unless user_signed_in?
        end
      end
    end
  end

  private

  def search_requested?
    !!query
  end

  def search_query_present?
    query.present?
  end

  def any_errors?
    !!@error
  end

  def query
    params[:q]
  end

  def extract_or_init_search_request_params
    params[:page] ||= 1
    params[:language] ||= ''
    params[:sort] ||= 'stars'
    params[:order] ||= 'desc'
  end

  def per_page
    30
  end

  def filter_language(items, language_filter)
    language_filter = '' if language_filter.downcase == 'all languages'
    return items unless language_filter.present?
    items.select! {|x| x['language'] == language_filter }
  end

  def extract_language_filters(items)
    return [''] if items.blank?
    ['All Languages', items.map{|m| m['language']}.uniq.reject{|m| m.blank?}].flatten
  end

  def build_next_url(q, page, filter='', sort='', order='')
    url = "/search?"
    url << "q=#{q}"
    url << "&page=#{page.to_i + 1}"
    url << "&language=#{filter}"
    url << "&sort=#{sort}"
    url << "&order=#{order}"
    url
  end

  def build_numeric_url(q, page, filter='', sort='', order='')
    url = "/search?"
    url << "q=#{q}"
    url << "&page=#{page.to_i}"
    url << "&language=#{filter}"
    url << "&sort=#{sort}"
    url << "&order=#{order}"
    url
  end

  def build_previous_url(q, page, filter='', sort='', order='')
    url = "/search?"
    url << "q=#{q}"
    url << "&page=#{page.to_i - 1}"
    url << "&language=#{filter}"
    url << "&sort=#{sort}"
    url << "&order=#{order}"
    url
  end
end
