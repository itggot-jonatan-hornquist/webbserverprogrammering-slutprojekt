require 'SQLite3'
require_relative 'dbhandler.rb'

class Logins < DBHandler

  set_table("Logins")

  def self.push_attempt(login_request)

    login_request.insert

  end

  def self.get_attempts(user_id)

    DB.execute('SELECT * FROM Logins WHERE user_id = ?', user_id)

  end

end
