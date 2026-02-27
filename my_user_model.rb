require 'sqlite3'

# IMPORTANT : les dernières instructionsen ruby ne mets pas de virgule sinon sa bloque tout ----> Exemple : lignes 27, 41, 51.

# Self allows the method to be called on the class itself (User.method) instead of on an instance of the class

class User
    attr_accessor :id, :firstname, :lastname, :age, :password, :email   # Allowing the instance variables set in initialize to be read and modified outside the class

    def initialize(user_hash)
        @id = user_hash["id"]
        @firstname = user_hash["firstname"]
        @lastname = user_hash["lastname"]
        @age = user_hash["age"]
        @password = user_hash["password"]
        @email = user_hash["email"]
    end

    # Database connection
    def self.data_base_connection
        data_base = SQLite3::Database.new("db.sql")
        data_base.results_as_hash = true
        
        # Create table if not exists
        data_base.execute <<-SQL
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,                    -- Primary key start at 0 and auto increment
                firstname VARCHAR(50),            
                lastname VARCHAR(50),
                age INTEGER CHECK (age >= 0 AND age <= 100),             -- Management of age between 0 and 100
                password VARCHAR(255),
                email VARCHAR(100)                                       -- Gérer la validation d'email, pour pas que l'on foute n'imp dans email
            );
        SQL
        
        data_base
    end

    # Function create a user_info : firstname, lastname, age, password, email ---> hash ; and it will return a unique ID (a positive integer)
    def self.create(user_info)
        data_base = data_base_connection
        data_base.execute(
            "INSERT INTO users (firstname, lastname, age, password, email) 
            VALUES (?, ?, ?, ?, ?)",                                    # Placeholders replaced safely by user values / execute take array at parameters
            [user_info[:firstname],
            user_info[:lastname],
            user_info[:age],
            user_info[:password],
            user_info[:email]]
        )
        user_id = data_base.last_insert_row_id                          # Return id of the last row insert in data_base
        data_base.close
        find(user_id)
    end


    # It will retrieve the associated user and return all information contained in the database
    def self.find(user_id)
        data_base = data_base_connection
        result = data_base.execute(
            "SELECT * FROM users WHERE id = ?",
            [user_id]
        )
        data_base.close
        return nil if result.empty?                                     # Return nil if result is empty : [].empty? -> true# Return nil if result is empty : [].empty? -> true
        User.new(result.first)
    end


    # It will return the email of user 
    def self.find_by_email(email)
        data_base = data_base_connection
        result = data_base.execute(
            "SELECT * FROM users WHERE email = ?", 
            [email]
        )
        data_base.close
        return nil if result.empty?
        User.new(result.first)
    end

    # It will retrieve all users and return a hash of users.
    def self.all
        # all_users << database (sql : all); boucle mettre dans result = {}
        data_base = data_base_connection
        all_users = data_base.execute("SELECT * FROM users")
        data_base.close

        users = {}
        all_users.each do |user|
            new_user = User.new(user)
            users[new_user.id] = new_user
        end
        users
    end

    # It will retrieve the associated user, update the attribute send as parameter with the value and return the user hash.
    def self.update(user_id, attribute, value)
        data_base = data_base_connection
        data_base.execute(
            "UPDATE users SET #{attribute} = ? WHERE id = ?",                   # Placeholders replaced safely by user values
            [value, user_id]
        )
        data_base.close
        find(user_id)
    end

    # It will retrieve the associated user and destroy it from your database.
    def self.destroy(user_id)
        data_base = data_base_connection
        user = find(user_id)
        return nil if user.nil?                                             # Error handling
        
        data_base.execute(
            "DELETE FROM users WHERE id = ?",
            [user_id]
        )
        data_base.close

        user
    end

    # Converts user object into hash
    def to_h
        {"firstname" => @firstname, "lastname" => @lastname, "age" => @age, "email" => @email}
    end
end