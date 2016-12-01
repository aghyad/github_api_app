require 'redis_store'

class GithubApiHandler
  include HTTParty
  base_uri 'api.github.com'

  attr_reader :options, :data_key

  def initialize(opts)
    opts[:sort] ||= :stars
    opts[:order] ||= :desc
    opts[:per_page] ||= 30
    opts[:page] ||= 1

    @options = {
      query: {
        q: opts[:q],
        sort: opts[:sort],
        order: opts[:order].to_sym,
        per_page: opts[:per_page],
        page: opts[:page]
      },
      headers: {
        "Authorization" => "Token #{opts[:user].encrypted_password}",
        "User-Agent" => "github_api_app"
      }
    }

    @data_key = "#{opts[:user].email}_search_repos_#{opts[:q]}_#{opts[:per_page]}_#{opts[:page]}_#{opts[:sort]}_#{opts[:order].to_sym}"
  end

  def search_repos
    cache_result = RedisStore.get(data_key)
    return cache_result if cache_result.present?

    Rails.logger.debug "\n%%%%% fetching remote data\n"
    remote_api_response = self.class.get('/search/repositories', options)

    if remote_api_response
      remote_api_parsed_response = remote_api_response.parsed_response

      if remote_api_parsed_response['message'].present?
        return {
          'ok'=> false,
          'message'=> "Error while connecting and searching GitHub API: \"#{remote_api_parsed_response['message']}\"",
          'data'=> {}
        }
      end

      Rails.logger.debug "\n%%%%% Caching the fetched data to #{data_key.inspect}\n\n"
      result = {
        'ok'=> true,
        'data'=> remote_api_parsed_response
      }
      RedisStore.set(data_key, result, 300)

      result
    else
      {
        'ok'=> false,
        'message'=> "Error while connecting and searching GitHub API: No response when requesting from GitHub API '/search/repositories'",
        'data'=> {}
      }
    end
  end
end
