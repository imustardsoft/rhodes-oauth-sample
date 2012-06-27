require 'rho/rhocontroller'
require 'helpers/browser_helper'

class AccountSetController < Rho::RhoController
  include BrowserHelper

  def index
    @account_set = AccountSet.find(:first)
  end
end
