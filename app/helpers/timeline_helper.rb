module TimelineHelper
  def screen_name(tweet)
    tweet['user']['name']
  end
  
  def suffix(tweet)
    '' # FIXME
  end
  
  def direct_message?(tweet)
    false # FIXME
  end
  
  def avatar(tweet)
    '' # FIXME
  end
  
  def formatted(tweet_text)
    tweet_text # FIXME
  end
  
  def pub_date(tweet)
    DateTime.parse(tweet.created_at).strftime("%a, %d %b %Y %H:%M:%S EST")
  end
end
