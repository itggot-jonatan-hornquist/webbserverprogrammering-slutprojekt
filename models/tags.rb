require 'Sinatra'
require 'SQLite3'

class Tags

    @db = SQLite3::Database.new('db/db.db')

    def self.get_tag_name_by_tag_id(id)
        @db.execute('SELECT name
                    FROM Tags
                    WHERE id = ?', id)
    end

end