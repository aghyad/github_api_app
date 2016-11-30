class RedisStore

  def self.redis
    uri = get_redis_uri
    @redis ||= Redis.new(:url => uri)
  end

  def self.get key
    res = redis.get(key)
    JSON.parse(res) if res
  end

  def self.set key, val, expiration=120
    redis.setex(key, expiration, val.to_json)
  end

  private

  REDIS_URL_NON_PRODUCTION = "redis://localhost:6379/"
  REDIS_URL_PRODUCTION = ENV["REDIS_URL"]
  HEROKU_DEPLOYMENT = ENV['HEROKU_DEPLOYMENT'] || true
  REDIS_URL_HEROKU_PRODUCTION = ENV["REDISTOGO_URL"]

  def self.get_redis_uri
    Rails.env.production? ? get_redis_uri_for_production : get_redis_uri_for_non_production
  end

  def self.get_redis_uri_for_production
    HEROKU_DEPLOYMENT ? REDIS_URL_HEROKU_PRODUCTION : REDIS_URL_PRODUCTION
  end

  def self.get_redis_uri_for_non_production
    REDIS_URL_NON_PRODUCTION
  end
end
