class TimelineController < ApplicationController
  include OauthSystem

  def index
    self.current_user = Member.find_by_token(params[:token])

    @tweets = []

    mentions(nil, nil, 20).each do |mention|
      @tweets << mention
    end

    direct_messages(nil, nil, 20).each do |direct_message|
      @tweets << direct_message
    end
  end
end
