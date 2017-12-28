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
        request.url "/v1.0/me/events?$top=20"
        request.headers["Authorization"] = "Bearer #{token}"
        request.headers["Accept"] = "application/json"
      end

      json_response = JSON.parse(response.body)
      @events = json_response['value']

      respond_to do |format|
        format.json { render json: json_response }
        format.html
      end
    else
      redirect_to root_path
    end
  end
end
