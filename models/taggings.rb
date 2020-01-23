require 'Sinatra'
require 'SQLite3'

class Taggings

    @db = SQLite3::Database.new('db/db.db')

    def self.get_tag_ids_by_post_id(id)

        # Doesn't work

        @db.execute('SELECT tag_id
                    FROM Taggings
                    WHERE post_id = ?', id)

    end

end