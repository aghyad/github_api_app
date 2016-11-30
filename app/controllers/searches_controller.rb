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
      @search_options = build_search_options

      @language_filters = nil
      @items = nil
      @error = nil

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

  def build_search_options
    {
      search_keyword: @search_keyword,
      page: @page,
      language_filter: @language_filter,
      sort: @sort,
      order: @order
    }
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
end
