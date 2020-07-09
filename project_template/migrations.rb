migrations = []
migrations << <<SQL
  CREATE TABLE IF NOT EXISTS test (
    id INT PRIMARY KEY
  );
SQL
migrations
