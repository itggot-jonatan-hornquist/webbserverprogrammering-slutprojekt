require 'Sinatra'
require 'SQLite3'
require 'net'
require 'http'
require 'net/http'

require_relative 'models/users.rb'
require_relative 'models/comments.rb'
require_relative 'models/posts.rb'
require_relative 'models/taggings.rb'
require_relative 'models/tags.rb'
require_relative 'models/logins.rb'

#TODO: Inloggningscheck i before
#         if request.get? && request.path != "/login" && session[:user_id].nil?
            # redirect '/login'
        # else
#TODO: Cooldown för inloggning
# Tabell med inloggningar (id, timestamp, ip)

#TODO: Kommentera funktioner/klasser

#TODO: Automatiska tester

class App < Sinatra::Base

    enable :sessions

    before do

        @db = SQLite3::Database.new('db/db.db')

        # Test for ez logins
        # session[:id] = [5]
        # session[:username] = "david"

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

        password_hash = User.get_password_hash_by_username(username)[1]

	      right_password = BCrypt::Password.new(password_hash)

        user_id = User.get_user_by_username(username)[0]["id"]
        attempt_hashes = Logins.get_attempts(user_id)
        attempts = []
        attempt_hashes.each do |attempt|
          attempts << Logins.new(attempt)
        end

        cooldown_minutes = 5

        recent_attempts = []
        attempts.each do |attempt|
          if (Time.now - Time.parse(attempt.time)) < cooldown_minutes*60
            recent_attempts << attempt
          end
        end

        max_recent_attempts = 3

        if recent_attempts.length <= max_recent_attempts


          if right_password == password

              p "Logged in."

              id = User.get_user_id_by_username(username)
              session[:id] = id
              session[:username] = username

              status = "success"


          else

              p "Login failed."

              status = "fail"

          end

        end

        # Security shit
        login_request = {"user_id" => nil,
                          "ip" => nil,
                          "time" => nil,
                          "status" => nil}


          login_request["user_id"] = User.get_user_id_by_username(username)["id"]
          login_request["ip"] = Net::HTTP.get('ipecho.net', '/plain')
          login_request["time"] = Time.now.to_s
          login_request["status"] = status

          login_request_object = Logins.new(login_request)
          Logins.push_attempt(login_request_object)

        status 200
        redirect '/'

    end

    get '/users/logout' do

        session[:id] = nil
        session[:username] = nil

        redirect '/'

    end

    get '/users/delete' do

      @user = User.new(User.get_user_by_id(session[:id]).first)
      session[:id] = nil
      session[:username] = nil
      @user.delete

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
