class MembersController < ApplicationController
  # include the oauth_system mixin
  include OauthSystem
  # specify oauth to be on all user-specific actions
  before_filter :oauth_login_required, :except => [ :callback, :signout, :index ]
  before_filter :init_member, :except => [ :callback, :signout, :index ]
  before_filter :access_check, :except => [ :callback, :signout, :index ]

  # controller method to handle twitter callback (expected after login_by_oauth invoked)
  def callback
      self.twitagent.exchange_request_for_access_token( session[:request_token], session[:request_token_secret], params[:oauth_verifier] )
      
      user_info = self.twitagent.verify_credentials
      
      raise OauthSystem::RequestError unless user_info['id'] && user_info['screen_name'] && user_info['profile_image_url']
      
      # We have an authorized user, save the information to the database.
      @member = Member.find_by_screen_name(user_info['screen_name'])
      if @member
          @member.token = self.twitagent.access_token.token
          @member.secret = self.twitagent.access_token.secret
          @member.profile_image_url = user_info['profile_image_url']
      else
          @member = Member.new({ 
              :twitter_id => user_info['id'],
              :screen_name => user_info['screen_name'],
              :token => self.twitagent.access_token.token,
              :secret => self.twitagent.access_token.secret,
              :profile_image_url => user_info['profile_image_url'] })
      end
      if @member.save!
          self.current_user = @member    
      else
          raise OauthSystem::RequestError
      end
      # Redirect to the show page
      redirect_to member_path(@member)
      
  rescue
      # The user might have rejected this application. Or there was some other error during the request.
      RAILS_DEFAULT_LOGGER.error "Failed to get user info via OAuth"
      flash[:error] = "Twitter API failure (account login)"
      redirect_to root_url
  end
  # GET /members
  # GET /members.xml
  def index
    if current_user
      @path = member_path(current_user)
    else
      @path = new_member_path
    end
  end

  def new
    # this is a do-nothing action, provided simply to invoke authentication
    # on successful authentication, user will be redirected to 'show'
    # on failure, user will be redirected to 'index'
  end
  
  # GET /members/1
  # GET /members/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end
  
  protected

  def init_member
    begin
      screen_name = params[:id] unless params[:id].nil?
      screen_name = params[:member_id] unless params[:member_id].nil?
      @member = Member.find_by_screen_name(screen_name)
      raise ActiveRecord::RecordNotFound unless @member
    rescue
      flash[:error] = 'Sorry, that is not a valid user.'
      redirect_to root_path
      return false
    end
  end
  
  def access_check
    return if current_user.id == @member.id
    flash[:error] = 'Sorry, permissions prevent you from viewing other user details.'
    redirect_to member_path(current_user) 
    return false    
  end  
end
