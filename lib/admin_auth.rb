module AdminAuth
private

  # not exactly enterprise grade security, but good enough for demo purposes
  def authenticate
    authenticate_or_request_with_http_basic("Intertwingly") do |user, password|
      password.crypt('intertwingly') == "infJpuvriVT0o"
    end
  end

end
