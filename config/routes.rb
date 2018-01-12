RestApiTest::Application.routes.draw do
  root to: 'home#index'
  get 'authorize' => 'auth#gettoken'
  get 'events/index'
  get 'calendar_view/index'
  get "extended_properties/new"
  post "extended_properties/create"
  post 'subscriptions/create'
  post 'notify' => 'notifications#handle'
end
