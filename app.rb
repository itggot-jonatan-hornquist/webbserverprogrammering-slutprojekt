require 'Sinatra'
require 'SQLite3'

require_relative 'models/users.rb'
require_relative 'models/comments.rb'
require_relative 'models/posts.rb'
require_relative 'models/taggings.rb'
require_relative 'models/tags.rb'

# TODO: FIXA CASCADING (ATT SAKER ASSOCIERADE TILL ANDRA SAKER I DATABASEN
# FÖRSVINNER)

class App < Sinatra::Base

    enable :sessions

    before do
        
        @db = SQLite3::Database.new('db/db.db')

        # Test for ez logins 
        session[:id] = [10]
        session[:username] = "test"

	end


    get '/users/?' do

        @users = User.get_all
        
        slim :'users/index'
        
    end
    
    get '/users/new' do

        user = {"username"=>nil, "password"=>nil}

        slim :'users/new'

    end

    post '/users/new' do 

        @db = SQLite3::Database.new('db/db.db')
        @users = User.get_all
        password = params['password']
        
        username = params['username']
        password_hash = BCrypt::Password.create(password)
        admin = 0
        creation_date = Time.now.to_s

        if username == nil || password == nil
            redirect '/users/new'
        end


        right_password = BCrypt::Password.new password_hash
        
        user_hash = {"username" => username,
                    "password_hash" => password_hash, "admin" => admin,
                    "creation_date" => creation_date}
        
        user_object = User.new(user_hash)
        
        User.create_account(user_object)
        
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

        if session[:username] != nil
            user_hash = User.get_user_by_username(session[:username]).first
            @user = User.new(user_hash)
        end

        byebug
        @user.delete


        @posts = Post.get_posts_for_view
        
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
                
        title = params['title']
        votes = 0
        content = params['content']
        creation_date = Time.now.to_s
        
        if title == nil || content == nil
            redirect '/posts/new'
        end

        creation_user_id = session[:id]

        max_post_id = Post.get_max_post_id.first.first[1]
        future_post_id = max_post_id + 1

        tag_1 = params['tag_1'][2..-3]
        tag_2 = params['tag_2'][2..-3]
        tag_3 = params['tag_3'][2..-3]

        # Check if .length is > 0 to find NIL
        # CAN'T HAVE TAGS UNDER THE 4 CHARACTERS

        tag_names = [tag_1, tag_2, tag_3]

        tag_ids = []
        tag_names.each do |tag_name|

            if tag_name.length > 3

                tag_id = Tags.get_tag_id_by_tag_name(tag_name).first.first

                tag_ids << tag_id

            end
            
        end
        
        tag_1 = tag_ids[0]
        tag_2 = tag_ids[1]
        tag_3 = tag_ids[2]

        post_hash = {"title" => title, "votes" => votes,
                    "content" => content, "creation_date" => creation_date,
                    "creation_user_id" => creation_user_id}

        post = Post.new(post_hash)
        
        Post.create_post(post)

        taggings_hash = {"post_id" => future_post_id, "tag_1" => tag_1, "tag_2" => tag_2, "tag_3" => tag_3}

        taggings = Taggings.new(taggings_hash)
        Taggings.create_taggings(taggings)

        redirect '/'

    end


    post '/posts/:id/upvote' do

        @post_id = params[:id].to_i
        
        post = Post.get(@post_id)

        Post.vote(post, 1)

        redirect "/posts/#{@post_id}"

    end
    
    post '/posts/:id/downvote' do

        @post_id = params[:id].to_i

        post = Post.get(@post_id)

        Post.vote(post, -1)

        redirect "/posts/#{@post_id}"

    end

    get '/posts/:id' do

        @post = Post.new(Post.get_post_by_post_id(params[:id]).first)
        @user = User.get_user_by_id(@post[5]).first
        @comments = Comments.get_comments_by_post_id_for_view(@post[0]).reverse
        @tags_ids = Taggings.get_tag_ids_by_post_id(params[:id])
        
        @tags = []
        @tags_ids.each do |tag_id|

            @tags << Tags.get_tag_name_by_tag_id(tag_id).first.first
        
        end
        
        
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