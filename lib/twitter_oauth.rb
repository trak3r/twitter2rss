#
#  code inspired by http://github.com/tardate/rails-twitter-oauth-sample
#
class TwitterOauth
  class GeneralError < StandardError
  end

  class APIError < TwitterOauth::GeneralError
  end

  class UnexpectedResponse < TwitterOauth::APIError
  end

  class APILimitWarning < TwitterOauth::APIError
  end

  # initialize the oauth consumer, and also access token if user_token and user_secret provided
  def initialize( user_token = nil, user_secret = nil )
    @consumer = OAuth::Consumer.new(TWOAUTH_KEY, TWOAUTH_SECRET, { :site=> TWOAUTH_SITE  })
    @access_token = OAuth::AccessToken.new( @consumer, user_token, user_secret ) if user_token && user_secret
  end

  # returns the consumer
  def consumer
    @consumer
  end

  # returns the access token, also initializes new access token if user_token and user_secret provided
  def access_token( user_token = nil, user_secret = nil )
    ( user_token && user_secret ) ? @access_token = OAuth::AccessToken.new( self.consumer, user_token, user_secret ) : @access_token
  end

  def access_token=(new_access_token)
    @access_token = new_access_token || false
  end

  # when the callback has been received, exchange the request token for an access token
  def exchange_request_for_access_token( request_token,  request_token_secret, oauth_verifier )
    #request_token = self.request_token( request_token, request_token_secret )
    request_token = OAuth::RequestToken.new(self.consumer, request_token, request_token_secret)
    #Exchange the request token for an access token. this may get 401 error
    self.access_token = request_token.get_access_token( :oauth_verifier => oauth_verifier )
  # rescue => err
  #   puts "Exception in exchange_request_for_access_token: #{err}"
  #   raise err
  end

  # gets a request token to be used for the authorization request to twitter
  def get_request_token( oauth_callback = TWOAUTH_CALLBACK )
    self.consumer.get_request_token( :oauth_callback => oauth_callback )
  end

  # twitter API methods

  # Twitter REST API Method: account verify_credentials
  def verify_credentials
    response = self.access_token.get('/account/verify_credentials.json')
    case response
    when Net::HTTPSuccess
      credentials=JSON.parse(response.body)
      raise TwitterOauth::UnexpectedResponse unless credentials.is_a? Hash
      credentials
    else
      raise TwitterOauth::APIError
    end
  # rescue => err
  #   puts "Exception in verify_credentials: #{err}"
  #   raise err
  end

  # Twitter REST API Method: direct_messages
  def results_from(command, since_id, max_id, count, page)
    params = ({
        :since_id => since_id,
        :max_id => max_id,
        :count => count,
        :page => page
        }.collect{|n| "#{n[0]}=#{n[1]}" if n[1]}
      ).compact.join('&')
    response = access_token.get("/#{command}.json" + 
      (params.empty? ? '' : '?' + params ))
    case response
    when Net::HTTPSuccess
      messages = JSON.parse(response.body)
      raise TwitterOauth::UnexpectedResponse unless messages.is_a? Array
      messages
    else
      # raise TwitterOauth::APIError
      raise response.inspect
    end
  # rescue => err
  #   puts "Exception in #{command}: #{err}"
  #   raise err
  end

  def direct_messages(since_id = nil, max_id = nil, count = nil, page = nil)
    results_from('direct_message', since_id, max_id, count, page)
  end

  def mentions(since_id = nil, max_id = nil, count = nil, page = nil)
    results_from('mentions', since_id, max_id, count, page)
  end

  def friends_timeline(since_id = nil, max_id = nil, count = nil, page = nil)
    results_from('friends_timeline', since_id, max_id, count, page)
  end

  def retweeted_to_me(since_id = nil, max_id = nil, count = nil, page = nil)
    results_from('retweeted_to_me', since_id, max_id, count, page)
  end
end
