# frozen_string_literal:true

Rails.application.routes.draw do
  # bot detection challenge
  get "/challenge", to: "bot_detection#challenge", as: :bot_detect_challenge
  post "/challenge", to: "bot_detection#verify_challenge"

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :iiif_search, BlacklightIiifSearch::Routes.new
  resources :collections, controller: 'oregon_digital/explore_collections', only: [] do
    collection do
      get :all, :osu, :uo, :my
    end
  end

  mount Bulkrax::Engine, at: '/'
  namespace :admin do
    resources :collection_types, except: :show, controller: 'oregon_digital/collection_types'
  end

  mount BrowseEverything::Engine => '/browse'
  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/'

  mount BlacklightAdvancedSearch::Engine => '/'

  get 'about' => 'oregon_digital/about#about'
  get 'osu-collection-policy' => 'oregon_digital/about#osu'
  get 'uo-collection-policy' => 'oregon_digital/about#uo'
  get 'copyright' => 'oregon_digital/about#copyright'
  get 'harmful' => 'oregon_digital/about#harmful'
  get 'privacy' => 'oregon_digital/about#privacy'
  get 'takedown' => 'oregon_digital/about#takedown'
  get 'terms' => 'oregon_digital/about#terms'
  get 'mission' => 'oregon_digital/about#mission'
  get 'use' => 'oregon_digital/about#use'
  get 'recommend' => 'oregon_digital/about#recommend'
  get 'local-contexts' => 'oregon_digital/about#local_contexts'

  patch '/contentblock/update/:name', to: 'oregon_digital/content_blocks#update', as: 'update_content_blocks'

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
      get :download_members
      get :export_members
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

  resources :iiif_manifest_v2, controller: 'oregon_digital/iiif_manifest_v2', path: '/iiif_manifest_v2', only: [:show]

  get '/robots.txt' => 'oregon_digital/robots#robots'

  post 'bulk_review/:ids', to: 'oregon_digital/reviews#approve_items', as: 'bulk_review'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

# OVERRIDE: Add in the download function towards the importers
Bulkrax::Engine.routes.draw do
  resources :exporters do
    get :download
    get :entry_table
    collection do
      get :exporter_table
    end
    resources :entries, only: %i[show update destroy]
  end

  resources :importers do
    put :continue
    get :entry_table
    get :export_errors, :download
    collection do
      get :importer_table
      post :external_sets
    end
    resources :entries, only: %i[show update destroy]
    get :upload_corrected_entries
    post :upload_corrected_entries_file
    get :verify
    get :show_errors
    get :show_do_export
  end
  get '/importers_all', to: 'importers#importers_list', as: 'importers_all'
end
