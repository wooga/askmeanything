require "jwt"

get '/auth/:provider/callback' do
  oauth_hash = request.env["omniauth.auth"]

  if oauth_hash && ENV['ACCESS_DOMAINS'].split(/,/).any? { |a| oauth_hash.info["email"] =~ /@#{a}$/ }
    session[:authenticated] = true
    token = oauth_hash.info["token"].split(' ').last
    decoded_token = JWT.decode(token, nil, false).first
    user = HashWithIndifferentAccess.new(
      email: decoded_token['upn'],
      first_name: decoded_token['given_name'],
      last_name: decoded_token['family_name']
    )
    session[:user] = {
      user: user,
      uid:  decoded_token['unique_name']
    }
    redirect session[:redirect_to] || '/'
  end
end

get '/auth/logout' do
  session[:authenticated] = false
  redirect '/'
end
