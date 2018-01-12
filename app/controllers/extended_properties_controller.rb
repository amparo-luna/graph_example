class ExtendedPropertiesController < ApplicationController
  include AuthHelper

  def new
  end

  def create
    token = access_token
    if token
      connection = Faraday.new(url: 'https://graph.microsoft.com') do |faraday|
        faraday.response :logger, ::Logger.new(STDOUT), bodies: true
        faraday.adapter Faraday.default_adapter
      end

      start_date_time = 1.day.from_now.change(hour: 11)
      event_body = {
        subject: params[:event_subject],
        start: {
          dateTime: start_date_time.iso8601,
          timeZone: 'UTC'
        },
        end: {
          dateTime: (start_date_time + 30.minutes).iso8601,
          timeZone: 'UTC'
        },
        extensions: [
          {
            "@odata.type": "Microsoft.Graph.OpenTypeExtension",
            "extensionName": "CampusData",
            "remote_calendar_configuration_id": "211",
            "campus_environment": "production",
            "originated_from_campus": true
          }
        ]
      }

      response = connection.post do |request|
        request.url "/v1.0/me/events"
        request.headers['Authorization'] = "Bearer #{token}"
        request.headers['Accept'] = 'application/json'
        request.headers['Content-Type'] = 'application/json'
        request.body = event_body.to_json
      end

      binding.pry
      if response.success?
        redirect_to events_index_path
      else
        redirect_to extended_properties_new_path
      end
    else
      redirect_to root_path
    end
  end
end
