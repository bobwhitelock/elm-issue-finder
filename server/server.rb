
require 'sinatra'
require 'sinatra_auth_github'

enable :sessions

set :github_options, {
  :scopes    => 'user',
  :secret    => ENV['GITHUB_CLIENT_SECRET'],
  :client_id => ENV['GITHUB_CLIENT_ID'],
}

register Sinatra::Auth::Github

get '/' do
  'Hmm'
end

get '/authenticate' do
  authenticate!
  redirect "http://localhost:3000?authenticated_github_user=#{github_user.login}"
end
