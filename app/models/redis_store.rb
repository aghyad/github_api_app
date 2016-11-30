class RedisStore

  def self.redis
    uri = ENV["REDISTOGO_URL"] || "redis://localhost:6379/"
    @redis ||= Redis.new(:url => uri)
  end

  def self.get key
    res = redis.get(key)
    JSON.parse(res) if res
  end

  def self.set key, val, expiration=120
    redis.setex(key, expiration, val.to_json)
  end
end
