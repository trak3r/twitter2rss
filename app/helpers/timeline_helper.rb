module TimelineHelper
  def cache_key
    # http://stackoverflow.com/questions/449271/how-to-round-a-time-down-to-the-nearest-15-minutes-in-ruby
    t = Time.now
    "#{current_user.screen_name}_#{(t-t.sec-t.min%15*60).strftime('%Y-%m-%d-%H-%M')}"
  end
  
  def suffix(tweet)
    return " (retweeted by #{tweet['user']['screen_name']})" if retweeted?(tweet)
    return " (@reply)" if reply?(tweet)
    return " (direct message)" if direct_message?(tweet)
    return " (search result reference)" if reference?(tweet)
    return ""
  end
  
  def id(tweet)
    begin
      tweet['retweeted_status']['id']
    rescue
      tweet['id']
    end
  end
  
  def retweeted?(tweet)
    !!tweet['retweeted_status']
  end

  def reply?(tweet)
    tweet['text'].starts_with?("@#{current_user.screen_name}")
  end

  def direct_message?(tweet)
    !tweet['sender'].nil?
  end

  def reference?(tweet)
    false
  end
  
  def text(tweet)
    begin
      tweet['retweeted_status']['text']
    rescue
      tweet['text']
    end
  end

  def formatted(tweet)
    "<span style=\"font-size:medium\">#{auto_link_ats(auto_link(CGI::unescapeHTML(text(tweet).gsub('&amp;','&'))))}</span>"
  end
  
  def auto_link_ats(text)
    text.gsub(/(^|\s)@([A-Za-z0-9_]+)/,'\1<a href="http://twitter.com/\2">@\2</a>')
  end  

  def avatar(tweet)
    "#{image_tag(profile_image_url(tweet), {:align => 'left', :height => 48, :width => 48, :style => 'padding-right:5px'})}"
  end

  def profile_image_url(tweet)
    tweet['user']['profile_image_url'] rescue tweet['sender']['profile_image_url']
  end

  def screen_name(tweet)
    begin
      tweet['retweeted_status']['user']['screen_name'] # Retweet
    rescue 
      begin
        tweet['user']['screen_name'] # Status
      rescue 
        begin
          tweet['sender_screen_name'] # DirectMessage
        rescue 
          begin
            tweet['from_user'] # SearchResult
          rescue
            '?'
          end
        end
      end
    end
  end

  def pub_date(tweet)
    DateTime.parse(tweet['created_at']).strftime("%a, %d %b %Y %H:%M:%S EST")
  end
end
