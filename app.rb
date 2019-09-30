require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require './models'

enable :sessions

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
  end
  if request.path_info == "/"
    if session[:user] == nil
      redirect '/signin'
    end
  end
end

get '/' do
  @counts = Count.all.order('id desc')
  erb :index
end

get '/signin' do
  erb :sign_in
end

get '/signup' do
  erb :sign_up
end

post '/signin' do
  user = User.find_by(username: params[:username])
  if user&& user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

post '/signup' do
  img_url = ''
  if params[:file]
    img = params[:file]
    tempfile = img[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload['url']
  end
  @user = User.create(username: params[:username], password:params[:password],password_confirmation:params[:password_confirmation],userimage: img_url)
  if @user.persisted?
    session[:user] = @user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user] = nil
  redirect '/signin'
end

get '/new' do
  erb :new
end

post '/new' do
  img_url = ''
  if params[:file]
    img = params[:file]
    tempfile = img[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload['url']
  end
  @count = Count.create(name: params[:title], number: 0,countimage: img_url,user_id: session[:user])
  redirect '/'
end

post '/counts/:id/add' do
  @user_count = UserCount.create(count_id: params[:id],user_id: session[:user])
  count = Count.find(params[:id])
  count.number = count.number + 1
  count.save
  redirect '/'
end

get '/counts/:id' do
  @count = Count.find(params[:id])
  @users = User.all
  @user_counts =UserCount.all
  erb :detail
end

post '/counts-detail/:id/add' do
  @user_count = UserCount.create(count_id: params[:id],user_id: session[:user])
  count = Count.find(params[:id])
  count.number = count.number + 1
  count.save
  redirect '/counts/' + params[:id]
end

get  '/user/:id' do
  @user = User.find(params[:id])
  @counts = Count.all
  @usercounts = UserCount.where(user_id: params[:id])
  erb :user
end

get '/search' do
  @counts = Count.where(name: params[:search])
  erb :index
end