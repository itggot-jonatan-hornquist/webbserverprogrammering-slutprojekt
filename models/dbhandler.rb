require 'SQLite3'

class DBHandler


    DB = SQLite3::Database.new('db/db.db')

    DB.results_as_hash = true

    def initialize(hash)

        hash.each do |key, value|

            instance_variable_set("@#{key}", value)
            singleton_class.send(:attr_accessor, key)            

        end
        
    end

    def self.get_all
        unints = DB.execute("SELECT * FROM #{@table}")

        ints = []

        unints.each do |unint|
            ints << self.new(unint)
        end

        return ints

    end

    def self.get(id)

        return self.new(DB.execute("SELECT * 
            FROM #{@table} 
            WHERE id = ?;", id).first) 

    end

    
    def insert()

        # Kräver att det finns ett "set_table("Table")" i klassen

        @insertable_vars_full = entity.instance_variables # Ta med namnen user.username osv
        
        @insertable_vars = []
        @insertable_values = []
        @insertable_vars_full.each do |var|
            @insertable_vars << var[1..-1]
            @insertable_values << entity.instance_variable_get(var)
        end

        @insertable_vars_str = @insertable_vars.join(", ")

        @question_marks = ""
        @insertable_vars.each do |key|
            @question_marks.concat("?,")
        end
        @question_marks = @question_marks[0..-2]

        DB.execute("INSERT INTO #{@table} (#{@insertable_vars_str}) 
                    VALUES (#{@question_marks})", @insertable_values)

    end

    def self.update(entity, column, value)
        
        DB.execute("UPDATE #{@table} SET #{column} = ?
            WHERE id = ?;", value, entity.id) # votes, post_id

    end

    def self.delete(entity)

        DB.execute("DELETE FROM #{@table}
                    WHERE id = ?;", entity.id)

    end
        



    def self.set_table(table)

        @table = table

    end



end