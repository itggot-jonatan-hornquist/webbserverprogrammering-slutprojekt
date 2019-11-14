require 'SQLite3'

class Seeder 

    def initialize
        @db = SQLite3::Database.new('db/db.db')

        nuke_all_tables

        create_tables
       

            # TEST DATA

        @db.execute('INSERT INTO Users (id, username, password_hash, admin, creation_date) VALUES (?,?,?,?,?)', "1", "bert", "273441934", "1", "right here right now")
        @db.execute('INSERT INTO Users (id, username, password_hash, admin, creation_date) VALUES (?,?,?,?,?)', "2", "bert2", "1273441934", "1", "right here right now")


    end

    def nuke_all_tables
        @db.execute('DROP TABLE IF EXISTS Comments')
        @db.execute('DROP TABLE IF EXISTS Posts')
        @db.execute('DROP TABLE IF EXISTS Taggings')
        @db.execute('DROP TABLE IF EXISTS Tags')
        @db.execute('DROP TABLE IF EXISTS Users')
    end

    def create_tables
        @db.execute <<-SQL
            CREATE TABLE "Comments" (
                "post_id"	INTEGER NOT NULL,
                "id"	INTEGER,
                "votes"	INTEGER NOT NULL,
                "content"	TEXT NOT NULL,
                "creation_date"	TEXT NOT NULL,
                "creation_user_id"	INTEGER NOT NULL UNIQUE,
                PRIMARY KEY("id")
            );
        SQL

        @db.execute <<-SQL
            CREATE TABLE "Posts" (
                "id"	INTEGER,
                "title"	TEXT NOT NULL,
                "votes"	INTEGER NOT NULL,
                "content"	TEXT NOT NULL,
                "creation_date"	TEXT NOT NULL,
                "creation_user_id"	INTEGER NOT NULL,
                PRIMARY KEY("id")
            );
        SQL

        @db.execute <<-SQL
            CREATE TABLE "Taggings" (
                "post_id"	INTEGER NOT NULL,
                "tag_id"	INTEGER NOT NULL 
            );
        SQL

        @db.execute <<-SQL
            CREATE TABLE "Tags" (
                "id"	INTEGER NOT NULL UNIQUE,
                "name"	TEXT NOT NULL UNIQUE
            );
        SQL

        @db.execute <<-SQL
            CREATE TABLE "Users" (
                "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
                "username"	TEXT NOT NULL UNIQUE,
                "password_hash"	TEXT NOT NULL,
                "admin"	INTEGER DEFAULT 0,
                "creation_date"	TEXT NOT NULL
            );
        SQL
    end

end



Seeder.new