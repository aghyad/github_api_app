class SearchesController < ApplicationController
  before_action :authenticate_user!

  def search
    if search_requested?
      ### Searching and instance vars
      extract_or_init_all_instance_variables_and_params

      ### now, we do the search:
      if search_query_present?
        search_handler = Search.new(@search_keyword, @order, per_page, @page, current_user)
        search_handler.perform
        @language_filters = search_handler.extract_language_filters
        @items = search_handler.by_language(@language_filter)
        @error = search_handler.response_error_message

        unless search_handler.response_ok?
          flash[:alert] = @error
          redirect_to home_request_authentication_path unless user_signed_in?
        end
      end
    end
  end

  private

  def extract_or_init_all_instance_variables_and_params
    extract_or_init_search_request_params

    @search_keyword = query
    @page = params[:page]
    @language_filter = params[:language]
    @sort = params[:sort]
    @order = params[:order]

    @language_filters = nil
    @items = nil
    @error = nil

    @search_options = {
      search_keyword: @search_keyword,
      page: @page,
      language_filter: @language_filter,
      sort: @sort,
      order: @order
    }
  end

  def extract_or_init_search_request_params
    params[:page] ||= 1
    params[:language] ||= ''
    params[:sort] ||= 'stars'
    params[:order] ||= 'desc'
  end

  def search_requested?
    !!query
  end

  def search_query_present?
    query.present?
  end

  def query
    params[:q]
  end

  def per_page
    30
  end
end
