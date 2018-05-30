class SubscriptionsController < ApplicationController
  include AuthHelper

  def index
    @subscriptions = Subscription.all
  end

  def create
    token = access_token
    if token
      connection = Faraday.new(url: api_url) do |faraday|
        faraday.response :logger, ::Logger.new(STDOUT), bodies: true
        faraday.adapter Faraday.default_adapter
      end

      response = connection.post do |request|
        request.url subscription_endpoint
        request.headers['Authorization'] = "Bearer #{token}"
        request.headers['Accept'] = 'application/json'
        request.headers['Content-Type'] = 'application/json'
        request.body = request_body.to_json
      end

      json_response = JSON.parse(response.body)
      if response.success?
        Subscription.create(body: json_response)
        redirect_to subscriptions_path
      else
        flash[:warning] = "Subscription creation failed with error: #{json_response}"
        redirect_to root_path
      end
    end
  end

  private

  def use_outlook_api?
    params[:use_outlook].present?
  end

  def api_url
    use_outlook_api? ? 'https://outlook.office.com' : 'https://graph.microsoft.com'
  end

  def subscription_endpoint
    if use_outlook_api?
      '/api/v2.0/me/subscriptions'
    else
      '/v1.0/subscriptions'
    end
  end

  def request_body
    if use_outlook_api?
      {
        "@odata.type": "#Microsoft.OutlookServices.PushSubscription",
        ChangeType: 'Created,Updated,Deleted',
        ClientState: 'SubscribingToOffice',
        NotificationURL: NOTIFY_URL,
        Resource: "https://outlook.office.com/api/v2.0/me/events?$filter=isAllDay eq true&$select=start,end,subject"
      }
    else
      {
        changeType: 'created,updated,deleted',
        clientState: 'subscribingToGraph',
        notificationUrl: NOTIFY_URL,
        resource: "/me/events?$filter=showAs eq 'free'",
        expirationDateTime: 2.days.from_now.iso8601
      }
    end
  end
end
