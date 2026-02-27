require 'sinatra'
require 'json'
require_relative './my_user_model.rb'

 # GET    -> read
# POST   -> create
# PUT    -> update
# DELETE -> delete

 # Global settings
enable :sessions
set :port, 8080
set :bind, '0.0.0.0'

 # GET / ---> return html page : index.html
get '/' do
    @users = User.all.values
    erb :index
end

 # GET /users --> return all users (without their passwords)
get '/users' do
    content_type :json
    users = User.all
    
    result = {}
    users.each do |id, user|                        # 2 parameters for access séparately key (ID of user) and value (data of user)
        user_hash = user.to_h.dup                   # .dup --> duplicate
        user_hash.delete("password")
        result[id.to_s] = user_hash                 # to_s == to string
    end
    
    result.to_json
end

 # POST /users --> Receiving firstname, lastname, age, password and email. It will create a user and store in your database and returns the user created (without password).
post '/users' do
    user = User.create({
        firstname: params["firstname"],
        lastname: params["lastname"],
        age: params["age"],
        password: params["password"],
        email: params["email"]
    })
    user.to_h.reject {|k, _| k == "password"}.to_json                     # Remove the password key for key / value when keyy is pass
end

 # POST /sign_in --> Receiving email and password. It will add a session containing the user_id in order to be logged in and returns the user created (without password).
post '/sign_in' do
    content_type :json
    email = params["email"]
    password = params["password"]

    user = User.find_by_email(email)

    if user && user.password == password
        session[:user_id] = user.id
        return user.to_h.reject { |k, _| k == "password" }.to_json
    else
        status 401
        return { error: "login failed" }.to_json
    end
end

 # PUT /users --> This action require a user to be logged in. It will receive a new password and will update it. It returns the user created (without password).
 put '/users' do
    if session[:user_id]
      pass = params["password"]
      if pass && !pass.empty?
        user = User.update(session[:user_id], "password", pass)
        return user.to_h.reject { |k, _| k == "password" }.to_json
      else
        status 401
        return { error: "failed" }.to_json
      end
    else
      status 401
      return { error: "failed" }.to_json
    end
  end

 # DELETE /sign_out --> This action require a user to be logged in. It will sign_out the current user. It returns nothing (code 204 in HTTP).
delete '/sign_out' do
    if session[:user_id]
        session.clear
        status 204
    else
        status 401
        return { error: "sign_out failed" }.to_json
    end
end

 # DELETE /users --> This action require a user to be logged in. It will sign_out the current user and it will destroy the current user. It returns nothing (code 204 in HTTP).
delete '/users' do
    if session[:user_id]
        User.destroy(session[:user_id])
        session.clear
        status 204
    else
        status 401
        return { error: "delete failed" }.to_json
    end
end