require 'resque'
require 'resque-scheduler'
require 'resque/scheduler/server'

Rails.application.routes.draw do

  root 'application#index'

  mount Resque::Server.new, :at => '/resque'

  devise_for :users

  get 'alerts' => 'maintenance_alerts#index'

  get 'spam' => 'la_tools#new'
  post 'spam' => 'la_tools#parse'
  post 'append_csv' => 'la_tools#append_csv'
  get 'dbl_surbl' => 'la_tools#dbl_surbl'
  post 'dbl_surbl' => 'la_tools#dbl_surbl_check'
  get 'bulk_curl' => 'la_tools#bulk_curl'
  post 'bulk_curl' => 'la_tools#perform_bulk_curl'
  get 'resource_abuse' => 'la_tools#resource_abuse'
  get 'html_pdfier' => 'la_tools#html_pdfier'
  post 'pdfy_html' => 'la_tools#pdfy_html'

  get 'monthly_reports' => 'manager_tools#monthly_reports'
  post 'monthly_reports' => 'manager_tools#generate_monthly_reports'
  get 'welcome_emails' => 'manager_tools#welcome_emails'
  post 'generate_welcome_emails' => 'manager_tools#generate_welcome_emails'

  get 'spam_reports'        => 'la_tools#spam_jobs', as: 'spam_reports'
  get 'spam_reports/:id'    => 'la_tools#show_spam_job', as: 'show_spam_report'
  delete 'spam_reports/:id' => 'la_tools#delete_spam_job', as: 'delete_spam_report'

  resources :abuse_reports
  get 'update_abuse_report_form' => 'abuse_reports#update_abuse_report_form'
  patch 'approve_abuse_report/:id' => 'abuse_reports#approve', as: 'approve_abuse_report'

  resources :hosting_abuse_reports do
    collection do
      get :update_form
    end
  end

  resources :nc_users
  resources :nc_services, as: 'nc_domains', path: '/nc_domains', controller: 'nc_domains'
  resources :nc_services, as: 'private_emails', path: '/private_emails', controller: 'private_emails'

  resources :rbls

  ##########################################################

  namespace :tools do
    resources :whois_lookups,   only: [:create]
    resources :bulk_whois_lookups do
      put :retry, on: :member
    end
    resources :data_searches,   only: [:create]
    resources :lists_diffs,     only: [:create]
    resources :bulk_digs,       only: [:create]
    resources :email_verifiers, only: [:create]
    resources :internal_domains
  end

  namespace :legal do
    resources :hosting_abuse do
      put :mark_processed,   on: :member
      put :mark_dismissed,   on: :member
      get :show_attach,      on: :member
    end
    resources :rbls
    namespace :rbl do
      resources :checkers,   only: [:create]
    end
    resources :pdf_reports do
      post :import,      on: :collection
      put  :toggle_edit, on: :member
      get  :download,    on: :member
      put  :merge,       on: :member
    end
  end

  namespace :domains do
    resources :watched_domains
  end

  resources :users
  resources :roles

end
