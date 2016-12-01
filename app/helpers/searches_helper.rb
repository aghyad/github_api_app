module SearchesHelper

  def next_url(search_options)
    build_pagination_numeric_url(search_options, search_options[:page].to_i + 1)
  end

  def previous_url(search_options)
    build_pagination_numeric_url(search_options, search_options[:page].to_i - 1)
  end

  def numeric_pagination_urls(search_options)
    build_numeric_pagination_urls(1..10, 1, search_options)
  end

  def build_numeric_pagination_urls(range=1..10, steps=1, search_options)
    [].tap do |arr|
      range.each do |num|
        if num % steps == 0
          arr << [ num, build_pagination_numeric_url(search_options, num) ]
        end
      end
    end
  end

  def build_pagination_numeric_url(search_options, num)
    url = "/search?"
    url << "q=#{search_options[:search_keyword]}"
    url << "&page=#{num}"
    url << "&language=#{search_options[:language_filter]}"
    url << "&sort=#{search_options[:sort]}"
    url << "&order=#{search_options[:order]}"
    url
  end

  def stars_ordering_url(search_options)
    return [] if search_options.blank?
    new_search_options = search_options
    new_search_options[:order] = (search_options[:order]=='desc' ? 'asc' : 'desc')
    # [
    #   (search_options[:order]=='desc' ? 'Stars [Desc]' : 'Stars [Asc]'),
    #   build_pagination_numeric_url(new_search_options, 1)
    # ]
    [
      'Stars',
      build_pagination_numeric_url(new_search_options, 1)
    ]
  end

  def build_stars_text_and_url(search_options)
    url_data = stars_ordering_url(search_options)
    return "Stars" if url_data.blank?
    link_to url_data[0].html_safe, url_data[1]
  end
end
