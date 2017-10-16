require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/wiki.db")

class User 
  include DataMapper::Resource 
    property :id, Serial 
    property :username, Text, :required => true 
    property :password, Text, :required => true 
    property :date_joined, DateTime 
    property :edit, Boolean, :required => true, :default => false 
end

DataMapper.finalize.auto_upgrade!

$myinfo = "Vitaly Amos"
@info = ""

def readFile(filename)
  info = ""
  file = File.open(filename)
  file.each do |line|
  info = info + line
  end
  file.close
  $myinfo = info
end

helpers do

def protected!
  if authorized?
  return
  end
  redirect '/denied'
end

def authorized?
  if $credentials != nil
  @Userz = User.first(:username => $credentials[0])
    if @Userz
      if @Userz.edit == true
      return true
      else
      return false
      end
    else
    return false
    end
  end
end

def current_user
      if $credentials
        if $credentials[0] != ' '
        User.first(:username => $credentials[0])
      else
        nil
        end
      end
end

def reset
    readFile("original.txt")
    @info = $myinfo 
    file = File.open("wiki.txt", "w")
    file.puts @info
    file.close
    
    reset_time = Time.now
    @reset_data = reset_time.strftime('%Y/%m/%d %H:%M %p') + " Reset by: " + current_user.username
    file = File.new("logs/#{reset_time.to_s}.txt", "w")
    file.puts @reset_data
    file.close
    redirect '/'
end

end

get '/' do
  info = "Hello there!"
  len = info.length
  len1 = len
  readFile("wiki.txt")
  @info = info + " " + $myinfo
  len = @info.length
  len2 = len - 1
  len3 = len2 - len1
  @words = len3.to_s
  erb :home
end

get '/about' do
  erb :about
end

get '/create' do
  erb :create
end

get '/edit' do
  protected!
  info = ""
  file = File.open("wiki.txt")
  file.each do |line|
  info = info + line
  end
  file.close
  @info = info
  erb :edit
end

put '/edit' do
  info = "#{params[:message]}"
  @info = info
  file = File.open("wiki.txt", "w")
  file.puts @info
  file.close
  
  update_time = Time.now
  @update_data = update_time.strftime('%Y/%m/%d %H:%M %p') + " Edited by: " + current_user.username
  file = File.new("logs/#{update_time.to_s}.txt", "w")
  file.puts @update_data
  file.close
  redirect '/'
end

get '/login' do 
  erb :login 
end

post '/login' do
  $credentials = [params[:username],params[:password]] 
  @Users = User.first(:username => $credentials[0]) 
    if @Users 
      if @Users.password == $credentials[1]
        redirect '/' 
      else
        $credentials = [' ',' '] 
        redirect '/wrongaccount'
      end
      else
        $credentials = [' ',' '] 
        redirect '/wrongaccount' 
    end 
end

get '/wrongaccount' do 
  erb :wrongaccount 
end

get '/user/:uzer' do
  @Userz = User.first(:username => params[:uzer]) 
    if @Userz != nil
    erb :profile else
    redirect '/noaccount'
    end
end

get '/createaccount' do 
  erb :createaccount 
end

post '/createaccount' do 
  n = User.new
  n.username = params[:username]
  n.password = params[:password]
  n.date_joined = Time.now 
    if n.username == "Admin" and n.password == "Password"
    n.edit = true
    end
  n.save 
  redirect '/' 
end

get '/logout' do 
  $credentials = [' ',' '] 
  redirect '/' 
end

get '/notfound' do
  erb :notfound
end

get '/noaccount' do
  erb :noaccount
end

get '/denied' do
  erb :denied
end

put '/user/:uzer' do
  n = User.first(:username => params[:uzer])
  n.edit = params[:edit] ? 1 : 0
  n.save
  redirect '/'
end

get '/user/delete/:uzer' do
  protected!
  n = User.first(:username => params[:uzer])
    if n.username == "Admin"
    erb :denied
    else
    n.destroy
    @list2 = User.all :order => :id.desc
    erb :admincontrols
    end
end

get '/admincontrols' do
  protected!
  @list2 = User.all :order => :id.desc
  erb :admincontrols
end

put '/reset' do
    reset
end

post '/archive' do
  readFile("wiki.txt")
  @info = $myinfo
  archived_time = Time.now
  file = File.new("archived/#{archived_time.to_s}.txt", "w")
  file.puts @info
  file.close
  redirect '/admincontrols'
end

not_found do
  status 404
  redirect '/notfound'
end