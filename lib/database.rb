require "sqlite3"
require_relative "./cipher.rb"

module Rubiclifier
  class DB
    SETTINGS_TABLE_MIGRATION = "CREATE TABLE IF NOT EXISTS settings (key VARCHAR(50) PRIMARY KEY, value TEXT, salt TEXT);"

    def self.hydrate(data_directory, migrations_location)
      system("mkdir -p \"#{data_directory.sub("~", "$HOME")}\"")
      @conn = SQLite3::Database.new(File.expand_path("#{data_directory}/data.sqlite3"))
      migrate_if_needed(migrations_location)
    end

    def self.conn
      Feature.fail_unless_enabled(Feature::DATABASE)
      @conn
    end

    def self.execute(sql)
      conn.execute(sql)
    end

    def self.query_single_row(sql)
      conn.execute(sql) do |row|
        return row
      end
      return nil
    end

    def self.get_setting(key)
      row = query_single_row("SELECT value, salt FROM settings WHERE key = '#{key}'")
      if row && row[1]
        Cipher.decrypt(row[0], row[1])
      elsif row
        row[0]
      end
    end

    def self.save_setting(key, value, is_secret:)
      salt = "NULL"
      if is_secret
        salt, encrypted = Cipher.encrypt(value)
        salt = "'#{salt}'"
        value = encrypted
      end
      conn.execute("DELETE FROM settings WHERE key = '#{key}';")
      conn.execute("INSERT INTO settings (key, value, salt) VALUES('#{key}', '#{value}', #{salt});")
    end

    def self.migrate_if_needed(migrations_location)
      all_migrations = [SETTINGS_TABLE_MIGRATION]
      all_migrations.concat(eval(File.read(migrations_location))) if migrations_location
      conn.execute("CREATE TABLE IF NOT EXISTS migrations (id INT PRIMARY KEY);")
      last_migration = query_single_row("SELECT id FROM migrations ORDER BY id DESC LIMIT 1;")&.to_a&.fetch(0) || -1
      if all_migrations.length - 1 > last_migration
        all_migrations[(last_migration + 1)..-1].each_with_index do |sql, i|
          conn.execute(sql)
          conn.execute("INSERT INTO migrations (id) VALUES (#{i + last_migration + 1});")
        end
      end
    end
  end
end
