RestApiTest::Application.routes.draw do
  root to: 'home#index'
  get 'authorize' => 'auth#gettoken'
  get 'events/index'
  get 'calendar_view/graph' => 'calendar_view#graph_index'
  get 'calendar_view/office' => 'calendar_view#office_index'
  get 'calendar_view/index'
  get "extended_properties/new"
  post 'extended_properties/create'
  post 'notify' => 'notifications#handle'
  get 'notifications/index'
  get 'instances/index'

  resources :subscriptions, only: [:index, :new, :create]
end
