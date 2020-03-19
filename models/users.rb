require 'SQLite3'
require_relative 'dbhandler.rb'

class User < DBHandler
        
    set_table("Users")

    def self.get_user_by_id(id)
        DB.execute('SELECT * 
                    FROM Users 
                    WHERE id = ?;', id)
    end

    def self.get_user_by_username(username)
        @db.execute('SELECT * 
                    FROM Users 
                    WHERE username = ?;', username)
    end

    def self.create_account(user_object)
        
        user_object.insert

    end

    def self.does_user_exist?(username)
        user = @db.execute('SELECT id FROM Users WHERE username = ?;', username).first

        if user != nil
            return true
        else
            return false
        end

    end

    def self.get_password_hash_by_username(username)
        @db.execute('SELECT password_hash FROM Users WHERE username = ?;', username).first.first
    end

    def self.get_user_id_by_username(username)
        @db.execute('SELECT id from Users WHERE username = ?;', username).first
    end

end

