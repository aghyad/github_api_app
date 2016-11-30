# require 'will_paginate/array'
class SearchesController < ApplicationController
  before_action :authenticate_user!

  def search
    if params[:q]
      params[:page] ||= 1
      params[:language] ||= ''
      params[:sort] ||= 'stars'
      params[:order] ||= 'desc'

      res = search_results
      if @error
        flash[:alert] = @error
        redirect_to home_request_authentication_path unless user_signed_in?
      else
        @error = nil
      end
    end
  end

  private

  def search_results
    per_page = 30

    @search_keyword = params[:q]
    @page = params[:page]
    @language_filter = params[:language]
    @sort = params[:sort]
    @order = params[:order]

    @next_url = build_next_url(@search_keyword, @page, @language_filter, @sort, @order)
    @numeric_pagination_urls = [].tap do |arr|
      (1..10).each { |num| arr << [num, build_numeric_url(@search_keyword, num, @language_filter, @sort, @order)] }
    end
    @previous_url = build_previous_url(@search_keyword, @page, @language_filter, @sort, @order)

    @stars_ordering_url = [
      (@order=='desc' ? 'Stars [Desc]' : 'Stars [Asc]'),
      build_numeric_url(@search_keyword, 1, @language_filter, @sort, (@order=='desc' ? 'asc' : 'desc'))
    ]

    if @search_keyword.present?
      handler = GithubApiHandler.new(@search_keyword, current_user.email, current_user.encrypted_password, :stars, @order.to_sym, per_page, @page)
      parsed_response = handler.search_repos

      if parsed_response['ok']
        parsed_response_items = parsed_response['data']['items'] || []
        @language_filters = extract_language_filters(parsed_response_items)
        final_items = filter_language(parsed_response_items, @language_filter)
        @items = final_items #.paginate(page: page, per_page: per_page)
      else
        @error = parsed_response['message']
      end

      # parsed_response_items = parsed_response[:data]['items'] || []
      # @language_filters = extract_language_filters(parsed_response_items)
      # final_items = filter_language(parsed_response_items, @language_filter)
      # @items = final_items
    end
  end

  def filter_language(items, language_filter)
    return items unless language_filter.present?
    items.select! {|x| x['language'] == language_filter }
  end

  def extract_language_filters(items)
    return [''] if items.blank?
    ['', items.map{|m| m['language']}.uniq.reject{|m| m.blank?}].flatten
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
