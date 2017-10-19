require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'diffy'

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

$myinfo = "" 
@info = ""

def readFile(filename)
  info = ""
  file = File.open(filename)
  file.each do |line|
  info = info + line + '<br>'
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
#Admin functionality to reset wiki to its original state as per basic spec
def reset
    readFile("original.txt")
    @info = $myinfo 
    file = File.open("wiki.txt", "w")
    file.puts @info
    file.close
    
    reset_time = Time.now
    @reset_data = reset_time.strftime('%Y/%m/%d %H:%M %p') + " Reset by: " + current_user.username
    file = File.open("log.txt", "a+")
    file.puts "\n" + @reset_data
    file.close
    redirect '/'
end

end

get '/' do
  @intro_text = "Some would say that there are individuals who just find programming too difficult. Others suggest that anyone can learn to programme if they set there mind 
        to it. What do you think? You can add your thoughts or edit this page by clicking on 'Edit' link on the top menu. Your text will appear below."
  readFile("wiki.txt")
  # wiki spec file asks for words and characters count but pdf spec file also shows line count, so all those counts are implemented 
  @file_info = $myinfo
  @words = @file_info.split(" ").length - 1
  @lines = File.readlines("wiki.txt").size - 1
  @chars_no_spaces = @file_info.gsub(/\s+/, '').length - (@lines+1) *4
  erb :home
end

get '/about' do
  erb :about
end

get '/edit' do
  protected!
  # we need additional variable to display text in edit view without br tags so we dont use readFile helper here
  info = ""
  file = File.open("wiki.txt")
  file.each do |line|
  info = info + line
  end
  file.close
  @file_info = $myinfo
  # we need to subtract a certain number or words, chars and lines as we added line breaks formatting so the lines are shown on the home page same way as on edit 
  @words = @file_info.split(" ").length - 1
  @lines = File.readlines("wiki.txt").size - 1
  @chars_no_spaces = @file_info.gsub(/\s+/, '').length - (@lines+1) *4
  @info = info
  erb :edit
end

put '/edit' do
  info = ""
  file = File.open("wiki.txt")
  file.each do |line|
  info = info + line
  end
  file.close
  @oldinfo = info
  
  # monitoring edits functionality suggested by extra spec
  
  # copying to temp file for comparison
  file = File.open("temp.txt","w")
  file.puts @oldinfo
  file.close
  # update wiki
  info = "#{params[:message]}"
  @info = info
  file = File.open("wiki.txt", "w")
  file.puts @info
  file.close
  
  # ascertain edit made vy using Diffy gem
  dif = Diffy::Diff.new("temp.txt", "wiki.txt", :source => 'files')
  
  #Recording edit date, time and username in a log file as per base spec 
  update_time = Time.now
  @update_data = update_time.strftime('%Y/%m/%d %H:%M %p') + " Edited by: " + current_user.username + "\n" + dif.to_s
  file = File.open("log.txt", "a+")
  file.puts "\n" + @update_data 
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
      #Recording login date, time and username in a log file as per extra spec 
      login_time = Time.now
      @login_data = login_time.strftime('%Y/%m/%d %H:%M %p') + " Login by: " + current_user.username
      file = File.open("log.txt", "a+")
      file.puts "\n" + @login_data 
      file.close
  
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
  @user = User.first(:username => params[:uzer]) 
    if @user != nil
    erb :profile
    else
    redirect '/noaccount'
    end
end

get '/user/edit/:uzer' do
  @user = User.first(:username => params[:uzer]) 
    if @user != nil
    erb :profile 
    else
    redirect '/noaccount'
    end
 end

  
put '/user/:uzer' do
 @list2 = User.all
 @user = User.first(:username => params[:uzer])
    profile_username = @user.username
    profile_password = @user.password
    profile_editor = current_user.username
    @user.username = params[:username]
    @user.password = params[:password]
    @user.edit = params[:edit] ? 1 : 0
    @user.save
    #Recording profile edit date, time and username in a log file as per extra spec. Also notes are added about changes. 
    profile_edit_time = Time.now
    note1 = ""
    note2 = ""
    if profile_username != @user.username  
       note1 = " Username changed to: " + params[:username] 
    end
    if profile_password != @user.password  
       note2 = " Password was changed"
    end
    @profile_edit_data = profile_edit_time.strftime('%Y/%m/%d %H:%M %p') + " Profile edited: " + profile_username + " Edited by: " + profile_editor + note1 + note2
    file = File.open("log.txt", "a+")
    file.puts "\n" + @profile_edit_data
    file.close
    if profile_editor == "Admin"
      redirect '/admincontrols'
    else 
      $credentials = [' ',' ']  
      redirect '/login'
    end
end


get '/createaccount' do 
  @user = User.new
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
  #Recording logout date, time and username in a log file as per extra spec 
  logout_time = Time.now
  @logout_data = logout_time.strftime('%Y/%m/%d %H:%M %p') + " Logout by: " + current_user.username
  file = File.open("log.txt", "a+")
  file.puts "\n" + @logout_data 
  file.close
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