require 'Sinatra'
require 'SQLite3'

class Taggings

    @db = SQLite3::Database.new('db/db.db')

    def self.get_tag_ids_by_post_id(id)

        @db.execute('SELECT tag_id
                    FROM Taggings
                    WHERE post_id = ?', id)

    end

    def self.create_taggings(tags)

        # TODO: Finish this

        

    end

end