require 'Sinatra'
require 'SQLite3'

class Database < Sinatra::Base

    @db = SQLite3::Database.new('db/db.db')

    def self.get_users
        p @db.execute('SELECT * FROM Users')
    end


end

test = Database.new

test.get_users