class SubscriptionsController < ApplicationController
  include AuthHelper

  def create
    token = access_token
    if token
      connection = Faraday.new(url: 'https://graph.microsoft.com') do |faraday|
        faraday.response :logger, ::Logger.new(STDOUT), bodies: true
        faraday.adapter Faraday.default_adapter
      end

      body = {
        changeType: 'created,updated,deleted',
        notificationUrl: NOTIFY_URL,
        resource: "me/events",
        expirationDateTime: 2.days.from_now.iso8601
      }

      response = connection.post do |request|
        request.url "/v1.0/subscriptions"
        request.headers['Authorization'] = "Bearer #{token}"
        request.headers['Accept'] = 'application/json'
        request.headers['Content-Type'] = 'application/json'
        request.body = body.to_json
      end
    end
    redirect_to root_path
  end
end
