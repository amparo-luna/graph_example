class NotificationsController < ApplicationController
  def handle
    if params[:validationToken]
      render status: :ok, text: params[:validationToken]
    elsif params['value']
      Rails.logger.debug { "Received notification: #{params['value']}" }
      render status: :accepted, text: 'ok'
    end
  end
end
