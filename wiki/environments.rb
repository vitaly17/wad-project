configure :development do
 DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/wiki.db")
 set :show_exceptions, true
end

configure :production do
 DataMapper::setup(:production, "postgres://gagwwsgcjyafam:f388bc87067ea34896abab26d435d5dbe7abbed1e48709d4da83c1ff35a2a6e3@ec2-46-51-187-253.eu-west-1.compute.amazonaws.com:5432/dc6dai6kjo0p9e")
end
