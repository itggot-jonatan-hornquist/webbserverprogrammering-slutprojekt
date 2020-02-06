require 'SQLite3'
require_relative 'dbhandler.rb'

class Tags < DBHandler

    @db = SQLite3::Database.new('db/db.db')

    def self.get_tag_name_by_tag_id(id)

        @db.execute('SELECT name
                    FROM Tags
                    WHERE id = ?', id)

    end

    def self.get_tag_id_by_tag_name(name)

        @db.execute('SELECT id
                    FROM Tags
                    WHERE name = ?', name)

    end

    def self.get_all_tag_names

        @db.execute('SELECT name
                    FROM Tags')

    end

end