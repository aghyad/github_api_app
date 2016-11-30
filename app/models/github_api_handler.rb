class GithubApiHandler
  include HTTParty
  base_uri 'api.github.com'

  def initialize(options)
    options[:sort] ||= :stars
    options[:order] ||= :desc
    options[:per_page] ||= 30
    options[:page] ||= 1

    @options = {
      query: {
        q: options[:q],
        sort: options[:sort],
        order: options[:order].to_sym,
        per_page: options[:per_page],
        page: options[:page]
      },
      headers: {
        "Authorization" => "Token #{options[:user].encrypted_password}",
        "User-Agent" => "github_api_app"
      }
    }

    @data_key = "#{options[:user].email}_search_repos_#{options[:q]}_#{options[:per_page]}_#{options[:page]}_#{options[:sort]}_#{options[:order].to_sym}"
  end

  def search_repos
    cache_result = RedisStore.get(@data_key)
    return cache_result if cache_result.present?

    Rails.logger.debug "\n%%%%% fetching remote data\n"
    remote_api_response = self.class.get('/search/repositories', @options)

    if remote_api_response
      remote_api_parsed_response = remote_api_response.parsed_response

      if remote_api_parsed_response['message'].present?
        return {
          'ok'=> false,
          'message'=> "Error while connecting and searching GitHub API: \"#{remote_api_parsed_response['message']}\"",
          'data'=> {}
        }
      end

      Rails.logger.debug "\n%%%%% Caching the fetched data to #{@data_key.inspect}\n\n"
      result = {
        'ok'=> true,
        'data'=> remote_api_parsed_response
      }
      RedisStore.set(@data_key, result, 300)

      result
    end
  end
end
