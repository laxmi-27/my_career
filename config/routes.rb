# plugins/my_career/config/routes.rb
Rails.application.routes.draw do
  match 'career/new', to: 'career#new', via: :get, as: 'new_career'
  match 'career', to: 'career#create', via: :post, as: 'career'
end
