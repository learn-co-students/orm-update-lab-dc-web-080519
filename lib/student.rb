require_relative "../config/environment.rb"

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def self.new_from_db(db_array)
    Student.new(db_array[1], db_array[2], db_array[0])
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql =
    <<-SQL
    SELECT * FROM students
    SQL

    DB[:conn].execute(sql).map { |row| self.new_from_db(row) }
  end

  def initialize(name, grade, id=nil)
    @name, @grade, @id = name, grade, id
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    self.new(name, grade).save
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql =
    <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.all_students_in_grade_9
    self.all.select do |student|
      student.grade == "9"
    end
  end

  def self.students_below_12th_grade
    self.all.select do |student|
      student.grade.to_i < 12
    end
  end

  def self.first_X_students_in_grade_10(number)
    self.all.select do |student|
      student.grade == "10"
    end[0...number]
  end

  def self.first_student_in_grade_10
    self.first_X_students_in_grade_10(1)[0]
  end

  def self.all_students_in_grade_X(grade)
    self.all.select do |student|
      student.grade.to_i == grade
    end
  end

end
