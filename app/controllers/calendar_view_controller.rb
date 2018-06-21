class CalendarViewController < ApplicationController
  include AuthHelper

  def index
  end

  def office_index
    token = access_token
    if token
      connection = Faraday.new(url: 'https://outlook.office.com') do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end

      sync_token = if params[:skip_token]
        "$skipToken=#{params[:skip_token]}"
      elsif params[:delta_token]
        "$deltaToken=#{params[:delta_token]}"
      end

      @first_sync_step = params[:start].nil? && params[:end].nil?
      @start_date_time = @first_sync_step ? 1.months.ago.beginning_of_day.iso8601 : params[:start]
      @end_date_time = @first_sync_step ? 1.months.from_now.end_of_day.iso8601 : params[:end]
      query_params = "startDateTime=#{@start_date_time}&endDateTime=#{@end_date_time}"
      query_params << "&#{sync_token}" if sync_token.present?

      response = connection.get do |request|
        request.url "/api/v2.0/me/calendarview?#{query_params}"
        request.headers['Authorization'] = "Bearer #{token}"
        request.headers['Accept'] = 'application/json'
        request.headers['Prefer'] = 'odata.maxpagesize=5,odata.track-changes'
      end

      json_response = JSON.parse(response.body)
      next_link = json_response['@odata.nextLink']
      @skip_token = next_link.split('skipToken=').last if next_link.present?

      delta_link = json_response['@odata.deltaLink']
      @initial_delta_token = delta_link.split('deltatoken=').last if delta_link.present? && delta_link.include?('deltatoken')
      @final_delta_token = delta_link.split('deltaToken=').last if delta_link.present? && delta_link.include?('deltaToken')

      @events = json_response['value']

      respond_to do |format|
        format.json { render json: json_response }
        format.html
      end
    else
      redirect_to root_path
    end
  end

  def graph_index
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
