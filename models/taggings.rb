require 'SQLite3'
require_relative 'dbhandler.rb'

class Taggings < DBHandler

    DB = SQLite3::Database.new('db/db.db')

    set_table("Taggings")

    def self.get_tag_ids_by_post_id(id)

        DB.execute('SELECT tag_id
                    FROM Taggings
                    WHERE post_id = ?', id)

    end

    def self.create_taggings(taggings)

        tags = [taggings.tag_1, taggings.tag_2, taggings.tag_3]

        viable_tag = {"post_id" => taggings.post_id, "tag_id" => nil}
        
        tags.each do |tag|
            if tag != nil
                viable_tag["tag_id"] = tag
                insertable_tag = Taggings.new(viable_tag)
                Taggings.insert(insertable_tag)
            end
        end

    end

end