Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/callback' => 'linebot#callback'
  get '/garbage' => 'linebot#garbage'
  post '/garbage_create' => 'linebot#garbage_create'
  get '/garbage_edit' => 'linebot#garbage_edit', as: "garbage_edit"
  patch '/garbage_update' => 'linebot#garbage_update'
  get '/garbage_delete' => 'linebot#garbage_destroy', as: "garbage_delete"
  get "/tomorrow_weather" => "weathers#tomorrow"
end
