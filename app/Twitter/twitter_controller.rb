require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'base64'
require 'hmac-sha1'
require 'time'


class TwitterController < Rho::RhoController
  include BrowserHelper

  def initialize
    @oauth_nonce = Time.now.to_i.to_s
    @oauth_timestamp = Time.now.to_i.to_s
    @http_port = System.get_property('rhodes_port')
    @oauth_callback_url = "http://127.0.0.1:" + @http_port.to_s + "/app/Twitter/callback"
    
    @url_param = "oauth_callback="+ Rho::RhoSupport.url_encode(@oauth_callback_url) + "&" +
                  "oauth_consumer_key="+ $oauth_consumer_key + "&" +
                  "oauth_nonce=" + @oauth_nonce + "&" +
                  "oauth_signature_method=" + $oauth_signature_method + "&" +
                  "oauth_timestamp=" + @oauth_timestamp + "&" +
                  "oauth_version="+ $oauth_version
    
  end

  def login
    request_token
    render :action => :wait
  end

  def callback

    request_access_res_body = get_access_token @params["oauth_verifier"]
    request_access_res_body.split("&").each do |response|
       if response.index("oauth_token=")
         $oauth_token = response["oauth_token=".length..(response.length - 1)]
       elsif response.index("oauth_token_secret=")
         $oauth_token_secret = response["oauth_token_secret=".length..(response.length - 1)]
       elsif response.index("user_id=")
         $userid = response["user_id=".length..(response.length - 1)]
       elsif response.index("screen_name=")
         $username = response["screen_name=".length..(response.length - 1)]
       end
    end

    AccountSet.find(:first).update_attributes(:tt_oauth_token => $oauth_token,
                                   :tt_oauth_token_secret => $oauth_token_secret)
    redirect :controller => 'AccountSet', :action => 'index'
  end

  def request_token_call_back
    request_token_res_body = @params["body"].split("&")
    $oauth_token = ""
    request_token_res_body.each do |response|
       if response.index("oauth_token=")
         $oauth_token = response["oauth_token=".length..(response.length - 1)]
       end
       if response.index("oauth_token_secret=")
         $oauth_token_secret = response["oauth_token_secret=".length..(response.length - 1)]
       end
    end
    WebView.navigate $request_redirect_url + $oauth_token
    render :nothing => true
  end

  private

  def get_access_token(oauth_verifier)
    @url_param =  "oauth_consumer_key="+ $oauth_consumer_key + "&" +
                  "oauth_nonce=" + @oauth_nonce + "&" +
                  "oauth_signature_method=" + $oauth_signature_method + "&" +
                  "oauth_timestamp=" + @oauth_timestamp + "&" +
                  "oauth_token=" + $oauth_token + "&" +
                  "oauth_verifier=" + oauth_verifier + "&" +
                  "oauth_version="+ $oauth_version

    access_res = Rho::AsyncHttp.post(:url => $request_access_token_url,
      :body => @url_param + "&oauth_signature=" + get_auth_signature(
       $request_access_token_url, @url_param, $oauth_token_secret)
    )

    access_res["body"]
  end


  def request_token
    Rho::AsyncHttp.post(:url => $request_token_url,
      :body => @url_param + "&oauth_signature=" + get_auth_signature($request_token_url, @url_param, ""),
      :callback => (url_for :action => :request_token_call_back)
    )
    render :action => :wait
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