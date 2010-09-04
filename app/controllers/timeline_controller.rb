class TimelineController < ApplicationController
  include OauthSystem

  def index
    self.current_user = Member.find_by_token(params[:token])
    @tweets = mentions
  end
end
