require 'SQLite3'

# Handles all interactions with the database
class DBHandler

  def self.set_table(table)

    @table = table

  end

  def self.table

    @table

  end

    DB = SQLite3::Database.new('db/db.db')

    DB.results_as_hash = true

    # Takes a hash and turns it into an object of any given class
    #
    # hash - a hash to be turned into an object
    #
    # Examples:
    # {"name" => "bert", "age" => 33}
    # #=> #<User:0006x1 @name="bert", @age=33>
    #
    # Returns object
    def initialize(hash)

        @table = self.class.table

        hash.each do |key, value|

            instance_variable_set("@#{key}", value)
            singleton_class.send(:attr_accessor, key)

        end

    end

    # Takes a table and returns everything on it as objects of that table
    #
    # self - table to be returned
    #
    # Examples:
    # users.get_all
    # #=> [#<User:0006x1 @name="bert", @age=33>]
    #
    # Returns a list of object
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

    # Inserts an object into its appropriate table by an sql request
    #
    # instance_variables - any object
    #
    # Examples:
    # @user.insert
    # #=> INSERT INTO Users (list of strings)
    #      VALUES (question mark for each stirng)", values for each string)
    #
    # Returns an SQl request
    def insert()

        # Kräver att det finns ett "set_table("Table")" i klassen
        @insertable_vars_full = self.instance_variables # Ta med namnen user.username osv
        @insertable_vars_full.shift(1) # Kinda frisky
        @insertable_vars = []
        @insertable_values = []
        @insertable_vars_full.each do |var|
            @insertable_vars << var[1..-1]
            @insertable_values << self.instance_variable_get(var)
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

    # Creates an sql request which updates a given entity
    #
    # entity - objects
    # column - variable of object
    # value - value of variable
    #
    # Examples:
    # User.update(@user, "name", "kent")
    # #=> Update Users SET name = ?
    #      WHERE id = ?;, "kent", @user.id
    #
    # Returns an SQl request
    def self.update(entity, column, value)

        DB.execute("UPDATE #{@table} SET #{column} = ?
            WHERE id = ?;", value, entity.id) # votes, post_id

    end

    # Creates an SQL request to delete an object
    #
    # entity - any object
    #
    # Examples:
    # @user.delete
    # #=> DELETE FROM Users WHERE id = ?, eneity.id
    #
    # Returns an SQl request
    def self.delete(entity)

        DB.execute("DELETE FROM #{@table}
                    WHERE id = ?;", entity.id)

    end







end
