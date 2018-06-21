class InstancesController < ApplicationController
  include AuthHelper

  def index
    token = access_token
    if token
      connection = Faraday.new(url: 'https://graph.microsoft.com') do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end

      @start_date_time = 1.months.ago.beginning_of_day.iso8601
      @end_date_time = 1.months.from_now.end_of_day.iso8601
      query_params = "startDateTime=#{@start_date_time}&endDateTime=#{@end_date_time}"
      query_params << "&$select=subject,organizer,start,end,type" if params[:short_event]
      query_params << "&$filter=type eq 'exception'" if params[:exceptions_only]

      response = connection.get do |request|
        request.url "/v1.0/me/events/#{params[:series_master]}/instances?#{query_params}"
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
