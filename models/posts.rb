require 'SQLite3'
require_relative 'dbhandler.rb'

class Post < DBHandler

    @db = SQLite3::Database.new('db/db.db')

    def self.get_posts

        @db.execute('SELECT * FROM Posts')
        
    end

    def self.get_post_by_post_id(id)

        @db.execute('SELECT * 
                    FROM Posts 
                    WHERE id = ?;', id)

    end

    def self.get_posts_by_user_id(id)

        @db.execute('SELECT * 
                    FROM Posts
                    WHERE creation_user_id = ?;', id)

    end

    def self.get_posts_for_view

        @db.execute('SELECT Posts.title, Posts.votes, Posts.content, Posts.creation_date, Users.username
            FROM Posts
            INNER JOIN Users 
            on Users.id = Posts.creation_user_id')

    end

    def self.create_post(title, votes, content, creation_date, creation_user_id)

        @db.execute('INSERT INTO Posts (title, votes, content, creation_date, creation_user_id) 
                    VALUES (?,?,?,?,?)',
                    title, votes, content, creation_date, creation_user_id)
        
        puts "Post created:\n      Title: #{title} \n      Votes: #{votes}\n      Content: #{content}\n      Creation time: #{creation_date}\n      Creation User Id:#{creation_user_id.first}"

    end

    def self.upvote(post_id)

        votes = @db.execute('SELECT Posts.votes
                            FROM Posts
                            WHERE id = ?;', post_id).first.first
        votes += 1

        @db.execute('UPDATE Posts
                    SET votes = ?
                    WHERE id = ?;', votes, post_id)

    end

    def self.downvote(post_id)

        votes = @db.execute('SELECT Posts.votes
                            FROM Posts
                            WHERE id = ?;', post_id).first.first
        votes -= 1

        @db.execute('UPDATE Posts
                    SET votes = ?
                    WHERE id = ?;', votes, post_id)

    end

    def self.get_max_post_id

        @db.execute('SELECT MAX(id)
                    FROM Posts;')

    end

end