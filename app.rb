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

        # Test for ez logins 
        session[:id] = [10]
        session[:username] = "test"

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
            
            p "Logged in."
            
            id = User.get_user_id_by_username(username)
            session[:id] = id
            session[:username] = username

            redirect '/'

        else
            
            p "Login failed."

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

        @posts = Post.get_posts.reverse
        
        slim :'posts/index'

    end

    get '/posts/new' do 

        @db = SQLite3::Database.new('db/db.db')
        @all_tags = Tags.get_all_tag_names

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

        # TODO: Fix this
        tags = "something"

        
        Post.create_post(title, votes, content, creation_date, creation_user_id)
        Taggings.create_taggings(tags)

        redirect '/'

    end

    post '/posts/:id/upvote' do

        post_id = params[:id].to_i

        Post.upvote(post_id)

        redirect "/posts/#{post_id}"

    end
    
    post '/posts/:id/downvote' do

        post_id = params[:id].to_i

        Post.downvote(post_id)

        redirect "/posts/#{post_id}"

    end

    get '/posts/:id' do

        @post = Post.get_post_by_post_id(params[:id]).first
        @user = User.get_user_by_id(@post[5]).first
        @comments = Comments.get_comments_by_post_id_for_view(@post[0]).reverse
        @tags_ids = Taggings.get_tag_ids_by_post_id(params[:id])
        
        @tags = []
        @tags_ids.each do |tag_id|

            @tags << Tags.get_tag_name_by_tag_id(tag_id).first.first
        
        end
        
        # TODO: List tag_ids associated to post_id
        #       Associate tag_ids with names

        
        slim :'posts/profile'

    end

    post '/posts/:id/' do

        @post = Post.get_post_by_post_id(params[:id]).first

        post_id = @post[0]
        votes = 0
        content = params['comment']
        creation_date = Time.now.to_s
        creation_user_id = session[:id].first

        Comments.create_comment(post_id, votes, content, creation_date, creation_user_id)

        redirect "/posts/#{post_id}"

    end

end