class TimelineController < ApplicationController
  include OauthSystem

  def index
    self.current_user = Member.find_by_token(params[:token])

    @tweets = []

    friends_timeline(nil, nil, 55).each do |tweet|
      @tweets << tweet
    end

    mentions.each do |mention|
      @tweets << mention
    end

    direct_messages.each do |direct_message|
      @tweets << direct_message
    end
    
    @tweets.sort! do |a, b|
      Date.parse(a['created_at']) <=> Date.parse(b['created_at'])
    end
  end
end
