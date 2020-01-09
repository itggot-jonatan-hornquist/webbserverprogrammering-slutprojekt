require 'Sinatra'
require 'SQLite3'

class Comments < Sinatra::Base

    @db = SQLite3::Database.new('db/db.db')

    def self.get_comments
        @db.execute('SELECT * FROM Comments')
    end

    def self.get_comments_by_post_id(id)
        @db.execute('SELECT * 
                    FROM Comments
                    WHERE post_id = ?;', id)
    end

    def self.get_comments_by_post_id_for_view(post_id)
        @db.execute('SELECT Comments.votes, Comments.content, Comments.creation_date, Users.username
            FROM Comments
            INNER JOIN Users 
            on Users.id = Comments.creation_user_id')
    end

    def self.get_comments_by_user_id(id)
        @db.execute('SELECT *
                    FROM Comments
                    WHERE creation_user_id = ?;', id)
    end

    def self.create_comment(post_id, votes, content, creation_date, creation_user_id)
        @db.execute('INSERT INTO Comments (post_id, votes, content, creation_date, creation_user_id)
                    VALUES (?,?,?,?,?)', 
                    post_id, votes, content, creation_date, creation_user_id)
    end

end
