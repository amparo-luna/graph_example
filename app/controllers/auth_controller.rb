class AuthController < ApplicationController
  include AuthHelper

  def gettoken
    token = token_from_code(params[:code])
    session[:azure_token] = token.to_hash
    redirect_to events_index_url
  end
end
