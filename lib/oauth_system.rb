# 
#  code mostly copied from http://github.com/tardate/rails-twitter-oauth-sample
# 
module OauthSystem
  class GeneralError < StandardError
  end
  
  class RequestError < OauthSystem::GeneralError
  end
  
  class NotInitializedError < OauthSystem::GeneralError
  end

  # controller method to handle logout
  def signout
    self.current_user = false 
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end
  
  protected
  
  # Inclusion hook to make #current_user, #logged_in? available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in? if base.respond_to? :helper_method
  end

  def twitagent( user_token = nil, user_secret = nil )
    self.twitagent = TwitterOauth.new( user_token, user_secret )  if user_token && user_secret
    self.twitagent = TwitterOauth.new( ) unless @twitagent
    @twitagent ||= raise OauthSystem::NotInitializedError
  end

  def twitagent=(new_agent)
    @twitagent = new_agent || false
  end

  # Accesses the current user from the session.
  # Future calls avoid the database because nil is not equal to false.
  def current_user
    @current_user ||= (login_from_session) unless @current_user == false
  end

  # Sets the current_user, including initializing the OAuth agent
  def current_user=(new_user)
    if new_user
      session[:twitter_id] = new_user.twitter_id
      self.twitagent( user_token = new_user.token, user_secret = new_user.secret )
      @current_user = new_user
    else
      session[:request_token] = session[:request_token_secret] = session[:twitter_id] = nil 
      self.twitagent = false
      @current_user = false
    end
  end

  def oauth_login_required
    logged_in? || login_by_oauth
  end

    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
  def logged_in?
    !!current_user
  end

  def login_from_session
    self.current_user = Member.find_by_twitter_id(session[:twitter_id]) if session[:twitter_id]
  end

  def login_by_oauth
    request_token = self.twitagent.get_request_token
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    # Send to twitter.com to authorize
    redirect_to request_token.authorize_url
  # rescue
  #   # The user might have rejected this application. Or there was some other error during the request.
  #   RAILS_DEFAULT_LOGGER.error "Failed to login via OAuth"
  #   flash[:error] = "Twitter API failure (account login)"
  #   redirect_to root_url
  end

  # controller wrappers for twitter API methods

  # Twitter REST API Method: statuses mentions
  def mentions( since_id = nil, max_id = nil , count = nil, page = nil )
    self.twitagent.mentions( since_id, max_id, count, page )
  # rescue => err
  #   RAILS_DEFAULT_LOGGER.error "Failed to get mentions via OAuth for #{current_user.inspect}"
  #   flash[:error] = "Twitter API failure (getting mentions)"
  #   return
  end

  # Twitter REST API Method: direct_messages
  def direct_messages( since_id = nil, max_id = nil , count = nil, page = nil )
    self.twitagent.direct_messages( since_id, max_id, count, page )
  # rescue => err
  #   RAILS_DEFAULT_LOGGER.error "Failed to get direct_messages via OAuth for #{current_user.inspect}"
  #   flash[:error] = "Twitter API failure (getting direct_messages)"
  #   return
  end

  def friends_timeline( since_id = nil, max_id = nil , count = nil, page = nil )
    self.twitagent.friends_timeline( since_id, max_id, count, page )
  # rescue => err
  #   RAILS_DEFAULT_LOGGER.error "Failed to get friends_timeline via OAuth for #{current_user.inspect}"
  #   flash[:error] = "Twitter API failure (getting friends_timeline)"
  #   return
  end

  def retweeted_to_me( since_id = nil, max_id = nil , count = nil, page = nil )
    self.twitagent.retweeted_to_me( since_id, max_id, count, page )
  # rescue => err
  #   RAILS_DEFAULT_LOGGER.error "Failed to get retweeted_to_me via OAuth for #{current_user.inspect}"
  #   flash[:error] = "Twitter API failure (getting retweeted_to_me)"
  #   return
  end
end
