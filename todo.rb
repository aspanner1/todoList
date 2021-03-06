require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"

configure do 
  enable :sessions
  set :session_secret, 'secret'
end 

before do 
  session[:lists] ||= []
end 

get "/" do 
  redirect "/lists"
end 


#View all the lists
get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

#Render the new lists form
get "/lists/new" do 
  erb :new_list, layout: :layout 
end 

#Return an error message if name is invalid. Return nil if name is valid
def error_for_list_name(name)
  if !(1..100).cover? name.size
    "List name must be between 1 and 100 characters"
  elsif session[:lists].any? {|list| list[:name] == name}
    "List name must be unique"
  end 
end 

def error_for_todo(name)
  if !(1..100).cover? name.size
    "Todo must be between 1 and 100 characters"
  end 
end 

#Create a new list
post "/lists" do 
  list_name = params[:list_name].strip

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else 
    session[:lists] << {name: list_name, todos: []}
    session[:success] = "The list has been created"
    redirect "/lists"
  end 
end 

get "/lists/:id" do 
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :list, layout: :layout
end 

#Edit existing todo list
get "/lists/:id/edit" do 
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :edit_list, layout: :layout 
end 

#Update existing todo list
post "/lists/:id" do
  list_name = params[:list_name].strip
  id = params[:id].to_i
  @list = session[:lists][id]

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else 
    @list[:name] = list_name
    session[:success] = "The list has been updated"
    redirect "/lists/#{id}"
  end 
end 

#Delete a todo list
post "/lists/:id/destroy" do 
  id = params[:id].to_i
  session[:lists].delete_at(id)
  session[:success] = "The list has been deleted"
  redirect "/lists"
end 

#Add new todo to a list
post "/lists/:list_id/todos" do 
  list_id = params[:list_id].to_i
  @list = session[:lists][list_id]
  text = params[:todo].strip

  error = error_for_todo(text)
  if error
    session[:error] = error
    erb :list, layout: :layout 
  else 
    @list[:todos] << {name: text, completed: false}
    session[:success] = "The todo was added"
    redirect "/lists/#{list_id}"
  end 
end 