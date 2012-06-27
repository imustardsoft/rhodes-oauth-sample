class AccountSet
  include Rhom::FixedSchema

  property :fb_access_token, :string
  property :fb_user_id, :string
  property :tt_oauth_token, :string
  property :tt_oauth_token_secret, :string
  property :fs_access_token, :string
end
