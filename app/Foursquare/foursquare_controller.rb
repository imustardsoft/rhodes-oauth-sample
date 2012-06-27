require 'rho/rhocontroller'
require 'helpers/browser_helper'

class FoursquareController < Rho::RhoController
  include BrowserHelper

  RedirectServiceURL = "http://redirectme.to"
  def initialize
    @http_port = System.get_property('rhodes_port')
    @oauth_callback_url = RedirectServiceURL + "/127.0.0.1:" + @http_port.to_s + "/app/Foursquare/callback"
    @oauth_access_token_callback_url = RedirectServiceURL + "/127.0.0.1:" + @http_port.to_s + "/app/Foursquare/access_token_callback"
  end
  
  def login
    url = $FS_REQUEST_TOKEN_URL + $FS_CLIENT_ID + "&display=touch&response_type=code&redirect_uri=" + @oauth_callback_url
    WebView.navigate(url)
  end

  def callback
    code = @params['code']
    url = $FS_REQUEST_ACCESS_TOKEN_URL + $FS_CLIENT_ID +
          "&client_secret=" + $FS_CLIENT_SECRET +
          "&grant_type=authorization_code&redirect_uri=" + @oauth_access_token_callback_url + 
          "&code=#{code}"
    access_res = Rho::AsyncHttp.get(:url => url)
    access_token =  access_res["body"]["access_token"]
    AccountSet.find(:first).update_attributes(:fs_access_token => access_token )
    redirect :controller => 'AccountSet', :action => 'index'
  end

  def access_token_callback
    
  end
end