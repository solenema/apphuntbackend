Rails.application.routes.draw do

 scope 'v1', defaults: {format: 'json'} do
    resources :apps, only: [:show, :index]
end
end
