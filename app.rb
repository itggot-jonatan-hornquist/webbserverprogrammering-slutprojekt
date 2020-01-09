require 'Sinatra'
require 'SQLite3'

require_relative 'models/users.rb'
require_relative 'models/comments.rb'
require_relative 'models/posts.rb'
require_relative 'models/taggings.rb'
require_relative 'models/tags.rb'

class App < Sinatra::Base

    enable :sessions


	before do 
		@db = SQLite3::Database.new('db/db.db')
	end


    get '/users/?' do
		@users = User.get_users
		slim :'users/index'
    end
    
    get '/users/new' do
        user = {"username"=>nil, "password"=>nil}

        slim :'users/new'
    end

    post '/users/new' do 
        @db = SQLite3::Database.new('db/db.db')
        @users = User.get_users
        password = params['password']
        
        id = @users.length
        username = params['username']
        password_hash = BCrypt::Password.create(password)
        admin = 0
        creation_date = Time.now

        if username == nil || password == nil
            redirect '/users/new'
        end


        right_password = BCrypt::Password.new password_hash        
        
        User.create_account(username, password_hash, admin, creation_date.to_s)
        redirect '/'
    end


    get '/users/login' do

        slim :'users/login'       

    end

    post '/users/login' do

        @db = SQLite3::Database.new('db/db.db')

		username = params['username']
        password = params['password']

        if !User.does_user_exist?(username) || username == nil
            redirect '/users/login'
        end
        
        password_hash = User.get_password_hash_by_username(username)
        
		right_password = BCrypt::Password.new(password_hash)
        
		if right_password == password
            p "logged in"
            
            id = User.get_user_id_by_username(username)
            session[:id] = id
            session[:username] = username
            redirect '/'
		else
            p "login failed"
        end
        status 200

    end

    get '/users/logout' do
        session[:id] = nil
        session[:username] = nil

        redirect '/'
    end

    get '/users/:username' do
        @user = User.get_user_by_username(params[:username]).first
        @posts = Post.get_posts_by_user_id(@user[0])
        slim :'users/profile'
    end



    get '/' do
        @posts = Post.get_posts_for_view
        slim :'posts/index'
    end

    get '/posts/new' do 

        if session[:id] == nil
            redirect '/users/login'
        end

        slim :'posts/new'

    end

    post '/posts/new' do
        
        @db = SQLite3::Database.new('db/db.db')
        
        title = params['title']
        votes = 0
        content = params['content']
        creation_date = Time.now.to_s
        
        if title == nil || content == nil
            redirect '/posts/new'
        end

        creation_user_id = session[:id]

        
        Post.create_post(title, votes, content, creation_date, creation_user_id)
        
        redirect '/'
    end

    get '/posts/:id' do

        @post = Post.get_post_by_post_id(params[:id]).first
        @user = User.get_user_by_id(@post[5]).first
        @comments = Comments.get_comments_by_post_id_for_view(@post[0])

        slim :'posts/profile'

    end


    # INGET AV DET HÄR FUNGERAR
    post '/posts/:id' do

        @post = Post.get_post_by_post_id(params[:id]).first
        @user = User.get_user_by_id(@post[5]).first
        @comments = Comments.get_comments_by_post_id_for_view(@post[0]).first

        Comments.create_comments(@post[0], 0, params['comment'], Time.now.to_s, session[:id])

        redirect '/:id'

    end


end