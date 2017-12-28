class CalendarViewController < ApplicationController
  include AuthHelper

  def index
    token = access_token
    if token
      connection = Faraday.new(url: 'https://graph.microsoft.com') do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end

      query_params = if params[:skip_token]
        "$skipToken=#{params[:skip_token]}"
      elsif params[:delta_token]
        "$deltaToken=#{params[:delta_token]}"
      else
        start_date_time = 1.months.ago.beginning_of_day.iso8601
        end_date_time = 1.months.from_now.end_of_day.iso8601
        "startDateTime=#{start_date_time}&endDateTime=#{end_date_time}"
      end

      response = connection.get do |request|
        request.url "/v1.0/me/calendarView/delta?#{query_params}"
        request.headers['Authorization'] = "Bearer #{token}"
        request.headers['Accept'] = 'application/json'
        request.headers['Prefer'] = 'odata.maxpagesize=5'
      end

      json_response = JSON.parse(response.body)
      next_link = json_response['@odata.nextLink']
      @skip_token = next_link.split('?$skiptoken=').last if next_link.present?

      delta_link = json_response['@odata.deltaLink']
      @delta_token = delta_link.split('$deltatoken=').last if delta_link.present?

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
