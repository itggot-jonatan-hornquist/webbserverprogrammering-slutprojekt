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
    
    def self.insert(hash)

        # TODO: Insert created object into database
        
        # INSERT INTO @table (#{array of insertable shit})
        # VALUES (#{number of question marks based on amount of attributes})
        # , #{array of insertable shit}

        # instance_variable_get

        # Converting the values of the hash to an array

        @insertable_keys = hash.keys
        @insertable_keys_str = hash.keys.join(", ")
        @insertable_values = hash.values.join(", ")

        byebug
        
        @question_marks = ""
        @insertable_keys.each do |key|
            @question_marks.concat("?,")
        end
        @question_marks = @question_marks[0..-2]

        DB.execute("INSERT INTO #{@table} (#{@insertable_keys_str}) 
                    VALUES (#{@question_marks})", @insertable_values)

                    # PROBLEM: @insert_values is a string
                    # and it shouldn't be


    end
        



    def self.set_table(table)

        @table = table

    end



end