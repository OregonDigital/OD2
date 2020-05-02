# frozen_string_literal:true

Rails.application.routes.draw do
  mount Bulkrax::Engine, at: '/'
  namespace :admin do
    resources :collection_types, except: :show, controller: 'oregon_digital/collection_types'
  end

  mount BrowseEverything::Engine => '/browse'
  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Blacklight::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions', registrations: 'users/registrations' }
  devise_scope :user do
    get 'users/auth/cas', to: 'users/omniauth_authorize#passthru', defaults: { provider: :cas }, as: 'new_osu_session'
    get 'users/auth/saml', to: 'users/omniauth_authorize#passthru', defaults: { provider: :saml }, as: 'new_uo_session'
  end

  # For Sidekiq administration UI
  authenticate :user, ->(u) { u.admin? } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Hydra::RoleManagement::Engine => '/'
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  mount Hyrax::Migrator::Engine, at: '/migrator'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  namespace :hyrax, path: :concern do
    concerns_to_route.each do |curation_concern_name|
      namespaced_resources curation_concern_name, only: [] do
        member do
          get :download_low, :download, :metadata
        end
      end
    end
  end

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
