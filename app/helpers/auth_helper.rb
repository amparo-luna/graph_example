module AuthHelper
  # Scopes required by the app
  SCOPES = [ 'openid',
             'email',
             'profile',
             'offline_access',
             'User.Read',
             'Calendars.Read'
           ]

  # Generates the login URL for the app.
  def office_login_url
    client.auth_code.authorize_url(redirect_uri: authorize_url, scope: SCOPES.join(' '))
  end

  def token_from_code(auth_code)
    client.auth_code.get_token(
      auth_code,
      :redirect_uri => authorize_url,
      :scope => SCOPES.join(' ')
    )
  end

  # Gets the current access token
  def access_token
    # Get the current token hash from session
    token_hash = session[:azure_token]
    token = OAuth2::AccessToken.from_hash(client, token_hash)

    # Check if token is expired, refresh if so
    if token.expired?
      new_token = token.refresh!
      # Save new token
      session[:azure_token] = new_token.to_hash
      new_token.token
    else
      token.token
    end
  end

  def client
    @client ||= OAuth2::Client.new(
      CLIENT_ID,
      CLIENT_SECRET,
      :site => 'https://login.microsoftonline.com',
      :authorize_url => '/common/oauth2/v2.0/authorize',
      :token_url => '/common/oauth2/v2.0/token'
    )
  end
end
