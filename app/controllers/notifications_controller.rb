class NotificationsController < ApplicationController
  def handle
    if params[:validationToken] # For Graph API
      Rails.logger.debug { "Validating token: #{params[:validationToken]}" }
      render status: :ok, text: params[:validationToken]
    elsif params[:validationtoken] # For Outlook Push Notifications REST API
      Rails.logger.debug { "Validating token: #{params[:validationtoken]}" }
      render status: :ok, text: params[:validationtoken]
    elsif params['value']
      Rails.logger.debug { "Received notification: #{params['value']}" }
      render status: :accepted, text: 'ok'
    end
  end
end
