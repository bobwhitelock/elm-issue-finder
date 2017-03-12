
require 'sinatra'
require 'sinatra_auth_github'

enable :sessions

set :github_options, {
  :scopes    => 'user', # TODO what scopes do we need?
  :secret    => ENV['GITHUB_CLIENT_SECRET'],
  :client_id => ENV['GITHUB_CLIENT_ID'],
  # TODO: change callback URL?
}

register Sinatra::Auth::Github

get '/api' do
  'Hmm'
end

get '/api/authenticate' do
  authenticate!
  redirect "http://localhost?authenticated_github_user=#{github_user.login}"
end

get '/api/retrieve-issues' do
  halt 401 unless github_user
  retrieve_stars(github_user).to_json
end

def retrieve_stars(github_user)
  stars = github_user.api.starred(github_user.login)
  stars.map { |s| s[:full_name] }
end
