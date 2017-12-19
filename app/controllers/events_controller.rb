class EventsController < ApplicationController
  include AuthHelper

  def index
    token = access_token
    if token
      connection = Faraday.new(url: 'https://graph.microsoft.com') do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end

      response = connection.get do |request|
        request.url "/v1.0/me/events"
        request.headers["Authorization"] = "Bearer #{token}"
        request.headers["Accept"] = "application/json"
      end

      @events = JSON.parse(response.body)['value']

      respond_to do |format|
        format.json { render json: @events }
        format.html
      end
    else
      redirect_to root_path
    end
  end
end
