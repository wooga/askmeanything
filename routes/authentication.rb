# Scopes are space separated strings
SCOPES = [
    'https://www.googleapis.com/auth/userinfo.email'
].join(' ')

get "/auth" do
  redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri,:scope => SCOPES,:access_type => "offline")
end

get '/oauth2callback' do
  access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)

  # parsed is a handy method on an OAuth2::Response object that will
  # intelligently try and parse the response.body
  @email = access_token.
    get('https://www.googleapis.com/userinfo/email?alt=json').
    parsed["data"]["email"]

  if @email =~ /[@]wooga.(net|com)$/ ||
      (ENV["ACCESS_EMAILS"] || "").split(",").include?(@email)
    session[:access_token] = access_token.token
    session[:username]     = @email.split(/[@]/).first.split(/[.]/).join(' ')
    session[:email]        = @email
    @message = "Successfully authenticated with the server"
    @access_token = session[:access_token]
    redirect '/'
  else
    "Access Denied for #{@email}"
  end
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/oauth2callback'
  uri.query = nil
  uri.to_s
end

def client
  client ||=
    OAuth2::Client.new(ENV['OAUTH_CLIENT_KEY'],
                       ENV['OAUTH_CLIENT_SECRET'], {
                         :site          => 'https://accounts.google.com',
                         :authorize_url => "/o/oauth2/auth",
                         :token_url     => "/o/oauth2/token"})
end
