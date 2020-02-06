require 'SQLite3'
require_relative 'dbhandler.rb'

class Taggings < DBHandler

    @db = SQLite3::Database.new('db/db.db')

    def self.get_tag_ids_by_post_id(id)

        @db.execute('SELECT tag_id
                    FROM Taggings
                    WHERE post_id = ?', id)

    end

    def self.create_taggings(post_id, tag_1, tag_2, tag_3)

        # TODO: Finish this

        tags = [tag_1, tag_2, tag_3]

        tags.each do |tag|

            if tag != nil
                
                @db.execute('INSERT INTO Taggings (post_id, tag_id) 
                            VALUES (?, ?)',
                            post_id, tag)

            end
        
        
        end


    end

end