require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication
  def initialize
    # Tab items are loaded left->right, @tabs[0] is leftmost tab in the tab-bar
    # Super must be called *after* settings @tabs!
    @tabs = nil
    #To remove default toolbar uncomment next line:
    #@@toolbar = nil
    super

    # Uncomment to set sync notification callback to /app/Settings/sync_notify.
    # SyncEngine::set_objectnotify_url("/app/Settings/sync_notify")
    SyncEngine.set_notification(-1, "/app/Settings/sync_notify", '')

    # FaceBook config
    $FB_API_ID = "272145592835609"
    $FB_API_SECRET = "1bc86e3e7268d5ac477dfe3f6fcb8856"
    $FB_AUTH_URL = "https://www.facebook.com/dialog/oauth"
    $FB_GRAPH_URL = "https://graph.facebook.com"

    # Twitter Config
    $oauth_consumer_key = "nX1qsXJZi7ZCYDAhTMd5xQ"
    $oauth_consumer_secret = "NRvWlkHFXv9hhYuPjDPxc0fQAC0XX4Qo4Ko1wshAk"
    $oauth_signature_method = "HMAC-SHA1"
    $oauth_version = "1.0"
    $request_token_url = "https://api.twitter.com/oauth/request_token"
    $request_redirect_url = "https://api.twitter.com/oauth/authenticate?oauth_token="
    $request_access_token_url = "https://api.twitter.com/oauth/access_token"

    # Foursquare Config
    $FS_CLIENT_ID = "WGZVZFISGTY3MCDUSNVRS20IY3QHTW531QIFFGVJAEP2LPUH"
    $FS_CLIENT_SECRET = "1SXVNYYDQK5GMLJWVMSVVKWALGEE4W15JD2W1ACQXIAGSNMK"
    $FS_REQUEST_TOKEN_URL = "https://foursquare.com/oauth2/authenticate?client_id="
    $FS_REQUEST_ACCESS_TOKEN_URL = "https://foursquare.com/oauth2/access_token?client_id="

    

    #
    if AccountSet.find(:first).nil?
      AccountSet.create(:fb_access_token => nil,
      :fb_user_id => nil,
      :tt_oauth_token => nil,
      :tt_oauth_token_secret => nil)
    end
  end
end
