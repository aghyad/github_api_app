class GithubApiHandler
  include HTTParty
  base_uri 'api.github.com'

  def initialize(query, username, u_token, sort=:stars, order=:desc, per_page=30, page=1)
    @options = {
      query: {
        q: query,
        sort: sort,
        order: order,
        per_page: per_page,
        page: page
      },
      headers: {
        "Authorization" => "Token #{u_token}",
        "User-Agent" => "github_api_app"
      }
    }
    puts u_token.inspect
    @data_key = "#{username}_search_repos_#{query}_#{per_page}_#{page}_#{sort}_#{order}"
    puts @data_key.inspect
  end

  def search_repos
    # - before fecthcing data from api, check in redis if the @data_key exists:
    cache_result = RedisStore.get(@data_key)

    # - if it does, return that value
    return cache_result if cache_result.present?

    # - else, continue with fetching data from remote api as below
    puts "\n\n%%%%%\nfetching remote data\n%%%%%\n\n"
    remote_api_response = self.class.get('/search/repositories', @options)
    puts remote_api_response.inspect

    if remote_api_response
      remote_api_parsed_response = remote_api_response.parsed_response

      if remote_api_parsed_response['message'].present?
        puts remote_api_parsed_response['message'].inspect
        return { 'ok'=> false, 'message'=> "Error while connecting and searching GitHub API: \"#{remote_api_parsed_response['message']}\"", 'data'=> {} }
      end

      # - then save the fetched data in redis (with expiration time of 5 mins), and name the key "<username>_search" and pass it back (or return nil if exceptions)
      puts "\n\n%%%%%\nCaching the fetching remote data\n%%%%%\n\n"
      result = { 'ok'=> true, 'data'=> remote_api_parsed_response }
      RedisStore.set(@data_key, result, 300)

      result
    end
  end
end
