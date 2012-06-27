require 'rho/rhocontroller'
require 'helpers/browser_helper'

class FacebookController < Rho::RhoController
  include BrowserHelper



  RedirectServiceURL = "http://redirectme.to"

  def facebook_callback
    #This is to achieve the effect of the "connecting" page
    token_result = Rho::AsyncHttp.get(
    :url => 'http://127.0.0.1:' + System.get_property('rhodes_port').to_s + url_for(:action => :facebook_check, :query => {'code' => @params['code']}),
    :callback => url_for(:action => :nothing)
    )

    $login_as = "Facebook"
    redirect :controller => 'AccountSet', :action => 'index'
  end

  def get_fb_token_url(code, previous_call_back)
    call_back_url = get_redirect_url(previous_call_back) #This is not going to be called by facebook, it is just to certify you have access to the token by providing the SAME URL that was given when requesting the token
    #call_back_url goes unencoded since Facebook requires it to be like that, hence it goes at the end of the request
    url = "#{$FB_GRAPH_URL}/oauth/access_token?client_id=#{$FB_API_ID}&client_secret=#{$FB_API_SECRET}&code=#{code}&redirect_uri=#{call_back_url}"
    return url
  end

  def facebook_check
    code = @params['code']
    token_url = get_fb_token_url(code, url_for(:action => :facebook_callback))
    #Since the "connecting" view is being displayed, we do the calls synchronously
    token_result = Rho::AsyncHttp.get(
      :url => token_url
    )

    if token_result['status'] == "ok"
      response = Rho::AsyncHttp.get(:url => "https://graph.facebook.com/me?#{token_result['body']}&fields=id,first_name,last_name")
      response_array = response['body'].split(',')
      id = response_array[0].split(':')[1].delete('\"')

      $facebook_user_id = id
      $facebook_access_token = token_result['body']
      AccountSet.find(:first).update_attributes(:fb_access_token => $facebook_access_token,
                                     :fb_user_id => $facebook_user_id)
    end
  end

  def get_redirect_url(local_callback_url)
    callback_url = RedirectServiceURL + '/127.0.0.1:' + System.get_property('rhodes_port').to_s + local_callback_url
    return callback_url
  end

  def login
    local_callback_url = url_for(:action => :facebook_callback)

    call_back_url = get_redirect_url(local_callback_url)
    url = "#{$FB_AUTH_URL}?display=touch&client_id=#{$FB_API_ID}" +
          "&scope=email,publish_stream,read_stream" +
          "&redirect_uri=#{call_back_url}"
    WebView.navigate(url)
  end

end
