require 'sinatra'
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

get '/' do
  info = "Hello there!"
  len = info.length
  len1 = len
  readFile("wiki.txt")
  @info = info + " " + $myinfo
  len = @info.length
  len2 = len - 1
  len3 = len2 - len1
  @info = @info + len3.to_s
  '<html><body>' +
  '<b>Menu</b><br>' +
  '<a href="/">Home</a><br>' +
  '<a href="/create">Create</a><br>' +
  '<a href="/about">About</a><br>' +
  '<a href="/edit">Edit</a><br>' +
  '<br><br>' + @info +
  '</body></html>'
end

get '/about' do
  '<html><body>' +
  '<b>Menu</b><br>' +
  '<a href="/">Home</a><br>' +
  '<a href="/create">Create</a><br>' +
  '<a href="/about">About</a><br>' +
  '<a href="/edit">Edit</a><br>' +
  '<br><br>' +
  '<h2>About us</h2>' +
  '<p>This wiki was created by </p>' + $myinfo +
  '<p>Staff ID: XXXXXXXX</p>' +
  '</body></html>'
end

get '/create' do
  '<html><body>' +
  '<b>Menu</b><br>' +
  '<a href="/">Home</a><br>' +
  '<a href="/create">Create</a><br>' +
  '<a href="/about">About</a><br>' +
  '<a href="/edit">Edit</a><br>' +
  '<br><br>' +
  '<h2>This is your own personal create page!</h2>' +
  '<section id="add">' + $myinfo + '</section>' +
  '</body></html>'
end

get '/edit' do
  info = ""
  file = File.open("wiki.txt")
  file.each do |line|
  info = info + line
  end
  file.close
  @info = info
  
  '<h2>Edit article</h2><br>' +
  '<form action="/edit" method="post" id="edit">' +
  '<input type="hidden" name="_method" value="put">' +
  '<textarea rows="20" cols="90" name="message">' + @info + '</textarea>' +
  '<input type="submit" value="Update">' +
  '</form>' +
  '<p><a href="../reset">Reset</a></p>'
end

put '/edit' do
  info = "#{params[:message]}"
  @info = info
  file = File.open("wiki.txt", "w")
  file.puts @info
  file.close
  redirect '/'
end

not_found do
  status 404
  redirect '/'
end
