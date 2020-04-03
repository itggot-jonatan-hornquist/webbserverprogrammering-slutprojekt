require 'SQLite3'
require_relative 'dbhandler.rb'

class Post < DBHandler

    set_table("Posts")

    def self.get_post_by_post_id(id)

        DB.execute('SELECT *
                    FROM Posts
                    WHERE id = ?;', id)

    end

    def self.get_posts_by_user_id(id)

        DB.execute('SELECT *
                    FROM Posts
                    WHERE creation_user_id = ?;', id)

    end

    def self.get_posts_for_view

        posts = DB.execute('SELECT Posts.id, Posts.title, Posts.votes, Posts.content, Posts.creation_date, Users.username
            FROM Posts
            INNER JOIN Users
            on Users.id = Posts.creation_user_id').reverse

        viewable_posts = []
        posts.each do |post|
            viewable_posts << Post.new(post)
        end

        return viewable_posts
    end

    def self.create_post(post)

        Post.insert(post)

    end

    def self.vote(post, value)

        votes = post.votes += value
        column = "votes"

        Post.update(post, column, votes)

    end


    def self.get_max_post_id

        DB.execute('SELECT MAX(id)
                    FROM Posts;')

    end

end
