class TimelineController < ApplicationController
  def index
    @member = Member.find_by_token(params[:token])
    @tweets = []
  end
end
