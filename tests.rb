# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

ActiveRecord::Migration.verbose = false

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_associate_terms_and_schools
    a = School.create(name: "Iron Yard")
    b = Term.create(name: "Spring Semester")
    a.terms << b
    assert_equal [b], a.terms
  end

  def test_associate_terms_with_courses_do_not_destroy_dependents
    a = Term.create(name: "Spring Semester")
    b = Course.create(name: "Ruby on Rails")
    a.courses << b
    assert_equal [b], a.courses
    begin
      a.destroy
      assert Course.where(id: b.id).empty?
    rescue
    end
  end

  def test_associate_courses_with_course_students_do_not_destroy_dependents
    a = Course.create(name: "Ruby on Rails")
    b = CourseStudent.create(student_id: 123)
    a.course_students << b
    assert_equal [b], a.course_students
    begin
      a.destroy
      assert CourseStudent.where(id: b.id).empty?
    rescue
    end
  end

  def test_associate_assignments_with_courses
    a = Course.create(name: "Ruby on Rails")
    b = Assignment.create(name: "Blackjack Advisor")
    a.assignments << b
    assert_equal [b], a.assignments
    begin
      a.destroy
      assert Assignment.where(id: b.id).empty?
    end
  end

  def test_associate_lessons_with_preclass_assignments
    a = Assignment.create(name: "Legacy Code")
    b = Lesson.create(name: "Associations and Validations")
    b.pre_class_assignment = a
    assert_equal a, b.pre_class_assignment
  end

  def test_set_up_a_school
    a = School.create(name: "Iron Yard")
    b = Course.create(name: "Ruby on Rails")
    c = Term.create(name: "Spring Semester")
    a.terms << c
    c.courses << b
    assert_equal [b], a.courses
  end
  
  def test_lessons_have_names
    a = Lesson.create(course_id: 123)
    refute a.valid?
  end

  # def test_readings_have_order_number_lesson_id_url
  #   a = Reading.create()
  # end



end

# Associate lessons with their pre_class_assignments (both directions).

#
# Validate that Readings must have an order_number, a lesson_id, and a url.
# Validate that the Readings url must start with http:// or https://. Use a regular expression.
# Validate that Courses have a course_code and a name.
# Validate that the course_code is unique within a given term_id.
# Validate that the course_code starts with three letters and ends with three numbers. Use a regular expression.
