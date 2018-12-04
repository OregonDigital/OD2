# frozen_string_literal:true

Rails.application.routes.draw do
  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Blacklight::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  devise_scope :user do
    get 'users/auth/cas', to: 'users/omniauth_authorize#passthru', defaults: { provider: :cas }, as: "new_osu_session"
    get 'users/auth/shibboleth', to: 'users/omniauth_authorize#passthru', defaults: { provider: :cas }, as: "new_uo_session"
  end

  mount Hydra::RoleManagement::Engine => '/'
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources :oembeds, controller: 'oregon_digital/oembeds', only: %i[index edit]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
