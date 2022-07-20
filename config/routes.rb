# frozen_string_literal:true

Rails.application.routes.draw do

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :iiif_search, BlacklightIiifSearch::Routes.new
  resources :explore_collections, controller: 'oregon_digital/explore_collections', only: [] do
    collection do
      get :all, :osu, :uo, :my
    end
  end

  namespace :admin do
    resources :collection_types, except: :show, controller: 'oregon_digital/collection_types'
  end

  mount BrowseEverything::Engine => '/browse'
  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  concern :oai_provider, BlacklightOaiProvider::Routes.new
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
    concerns :oai_provider
  end

  devise_for :users, controllers: { confirmations: 'users/confirmations', omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }
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
  scope module: 'hyrax' do
    namespace :admin do
      resource :workflows, only: [:index], as: 'workflows', path: '/workflows', controller: 'workflows' do
        concerns :range_searchable
      end
    end
  end

  resources :collections, controller: 'hyrax/collections', only: [] do # public landing show page
    member do
      get :download
    end
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
    concerns :iiif_search
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources :oembeds, controller: 'oregon_digital/oembeds', only: %i[index edit]

  post 'bulk_review/:ids', to: 'oregon_digital/reviews#approve_items', as: 'bulk_review'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
