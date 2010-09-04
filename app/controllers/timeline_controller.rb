class TimelineController < ApplicationController
  include OauthSystem

  def index
    current_user = Member.find_by_token(params[:token])
    @tweets = mentions
    raise @tweets.inspect
  end
end
