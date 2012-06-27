require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'base64'
require 'hmac-sha1'
require 'time'

class ShareController < Rho::RhoController
  include BrowserHelper

  def share
    comment = @params['share_content']
    @account_set = AccountSet.find(:first)
    if @account_set.fb_access_token
      post_to_facebook(comment)
    end

    if @account_set.tt_oauth_token
      post_to_twitter(comment)
    end

    if @account_set.fs_access_token
      post_to_foursquare(comment)
    end
  end

  private
  
  def post_to_facebook(comment)
    Rho::AsyncHttp.post(:url => "https://graph.facebook.com/#{@account_set.fb_user_id}/feed?#{@account_set.fb_access_token}&message=#{Rho::RhoSupport.url_encode(comment)}")
  end

  def post_to_twitter(comment)
    post_status_url = "https://api.twitter.com/1/statuses/update.json"
    post_status_param = "oauth_consumer_key="+ $oauth_consumer_key + "&" +
                        "oauth_nonce=" + Time.now.to_i.to_s + "&" +
                        "oauth_signature_method=" + $oauth_signature_method + "&" +
                        "oauth_timestamp=" + Time.now.to_i.to_s + "&" +
                        "oauth_token=" + @account_set.tt_oauth_token  + "&" +
                        "oauth_version="+ $oauth_version+ '&' +
                        "status=" + Rho::RhoSupport.url_encode(comment)

    Rho::AsyncHttp.post(
      :url => post_status_url,
      :body => post_status_param + "&oauth_signature=" + get_auth_signature(post_status_url, post_status_param, @account_set.tt_oauth_token_secret)
    )
  end

  def post_to_foursquare(comment)
    venue_id = "40a55d80f964a52020f31ee3"
    add_tip_url = "https://api.foursquare.com/v2/tips/add"
    add_tip_param = "venueId=#{venue_id}&text=#{Rho::RhoSupport.url_encode(comment)}&oauth_token=#{@account_set.fs_access_token}"
    Rho::AsyncHttp.post(
      :url => add_tip_url,
      :body => add_tip_param
    )
  end

  def get_auth_signature (url, url_param, secret)
    signature = "POST&" + Rho::RhoSupport.url_encode(url).to_s +
                "&" + Rho::RhoSupport.url_encode(url_param).to_s

    key = $oauth_consumer_secret + "&" + secret
    hmac = HMAC::SHA1.new(key)
    hmac.update(signature)
    Base64.encode64("#{hmac.digest}")
  end
end
