require 'rho/rhocontroller'
require 'helpers/browser_helper'

class SetController < Rho::RhoController
  include BrowserHelper

  def index
    @account_set = Set.find(:first)
  end

  def save
    @account_set = Set.find(:first)
    if @account_set
      @account_set.update_attributes(:fb_username => @params[:fb_username],
                         :fb_password => @params[:fb_password],
                         :tt_username => @params[:fb_username],
                         :tt_password => @params[:fb_password],
                         :fs_username => @params[:fs_username],
                         :fs_password => @params[:fs_password],
                         )
    else
       Set.create(:fb_username => @params[:fb_username],
                         :fb_password => @params[:fb_password],
                         :tt_username => @params[:fb_username],
                         :tt_password => @params[:fb_password],
                         :fs_username => @params[:fs_username],
                         :fs_password => @params[:fs_password],
                         )
    end
    @account_set = Set.find(:first)
    render :action => :index
  end
end
