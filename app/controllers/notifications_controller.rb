class NotificationsController < ApplicationController
  def index
    @notifications = Notification.all
  end

  def handle
    if params[:validationToken] # For Graph API
      Rails.logger.debug { "Validating token: #{params[:validationToken]}" }
      render status: :ok, text: params[:validationToken]
    elsif params[:validationtoken] # For Outlook Push Notifications REST API
      Rails.logger.debug { "Validating token: #{params[:validationtoken]}" }
      render status: :ok, text: params[:validationtoken]
    elsif params['value']
      Rails.logger.debug { "Received notification: #{params['value']}" }
      Notification.create(value: params['notification'])
      render status: :accepted, text: 'ok'
    end
  end
end
