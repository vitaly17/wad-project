require 'sinatra'
$myinfo = "Vitaly Amos"
@info = ""

get '/' do
  info = "Hello there!"
  @info = info + " " + $myinfo
  '<html><body>' +
  '<b>Menu</b><br>' +
  '<a href="/">Home</a><br>' +
  '<a href="/create">Create</a><br>' +
  '<a href="/about">About</a><br>' +
  '<br><br>' + @info +
  '</body></html>'
end

get '/about' do
  '<html><body>' +
  '<b>Menu</b><br>' +
  '<a href="/">Home</a><br>' +
  '<a href="/create">Create</a><br>' +
  '<a href="/about">About</a><br><br><br>' +
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
  '<a href="/about">About</a><br><br><br>' +
  '<h2>This is your own personal create page!</h2>' +
  '<section id="add">' + $myinfo + '</section>' +
  '</body></html>'
end

not_found do
  status 404
  redirect '/'
end