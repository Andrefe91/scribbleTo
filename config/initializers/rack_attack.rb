class Rack::Attack
  throttle('uniqueness_check/ip', limit: 10, period: 1.minute) do |req|
    if req.path == '/scribbles/check_uniqueness' && req.get?
      req.ip
    end
  end

  # Custom response when someone is throttled
  self.throttled_responder = lambda do |env|
    [429, { 'Content-Type' => 'application/json' }, [{ error: "Rate limit exceeded. Please slow down a little!" }.to_json]]
  end
end
