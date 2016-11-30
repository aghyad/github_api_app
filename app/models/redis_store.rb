class RedisStore

  def self.redis host='localhost', port=6379
    @redis ||= Redis.new(host: host, port: port)
  end

  def self.get key
    res = redis.get(key)
    JSON.parse(res) if res
  end

  def self.set key, val, expiration=120
    redis.setex(key, expiration, val.to_json)
  end
end
