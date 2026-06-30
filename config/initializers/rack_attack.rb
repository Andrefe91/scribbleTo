class Rack::Attack
  # TODO Add a whitelist for internal IPs to avoid throttling internal requests
  # TODO Add a thottling where the blocking time is different that the evaluated period time.
  # For example, if the limit is 20 requests per minute, we can block for 5 minutes if the limit is exceeded.
  throttle("Request by Ip", limit: 50, period: 1.minute) do |req|
    req.ip
  end

  throttle("uniqueness_check/ip", limit: 10, period: 1.minute) do |req|
    if req.path == "/scribbles/check_uniqueness" && req.get?
      req.ip
    end
  end

  # Custom response when someone is throttled
  self.throttled_responder = lambda do |env|
    [ 429, { "Content-Type" => "application/json" }, [ { error: "Rate limit exceeded. Please slow down a little!" }.to_json ] ]
  end
end
