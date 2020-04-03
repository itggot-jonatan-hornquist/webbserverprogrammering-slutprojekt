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
        DB.execute('SELECT *
                    FROM Users
                    WHERE username = ?;', username)
    end

    def self.create_account(user_object)

        user_object.insert

    end

    def self.does_user_exist?(username)
        user = DB.execute('SELECT id FROM Users WHERE username = ?;', username).first

        if user != nil
            return true
        else
            return false
        end

    end

    def self.get_password_hash_by_username(username)
        DB.execute('SELECT password_hash FROM Users WHERE username = ?;', username).first.first
    end

    def self.get_user_id_by_username(username)
      DB.execute('SELECT id from Users WHERE username = ?;', username).first
    end


    # Takes a user object, deletes the user and all the comments and posts associaated with them
    def delete

        user_id = self.id
        tables = ["Posts", "Comments"]
        DB.execute("DELETE FROM Users WHERE id = #{user_id}")

        tables.each do |table|
          DB.execute("DELETE FROM #{table} WHERE creation_user_id = #{user_id}")
          puts "Deleted thing(s) from #{table} by user_id #{user_id}"
        end


    end

end
