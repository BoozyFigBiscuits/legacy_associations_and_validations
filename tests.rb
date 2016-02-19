# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

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

  def test_readings_delete_with_lessons
    l = Lesson.create(name: "Lemons")
    r = Reading.create(caption: "Rider")
    l.readings << r
    assert_equal [r], l.readings
    l.destroy
    assert Reading.where(id: r.id).empty?
  end

  def test_lessons_delete_with_course
    c = Course.create(name: "Ruby")
    l = Lesson.create(name: "Rails")
    c.lessons << l
    assert_equal [l], c.lessons
    c.destroy
    assert Lesson.where(id: l.id).empty?
  end

  def test_courses_cant_delete_if_has_course_instructors
    c = Course.create(name: "Ruby")
    ci = CourseInstructor.create!(instructor_id: 10)
    c.course_instructors << ci
    assert_equal [ci], c.course_instructors
    begin
    c.destroy
    rescue
    end
    refute Course.where(id: c.id).empty?
  end

  def test_lessons_with_inclass_assignments
    skip
    l = Lesson.create(name: "Lemons")
    l.in_class_assignment_id = 13
    assert 13, l.in_class_assignment_id
  end

  def test_readings_through_lessons
    c = Course.create(name: "Ruby")
    l = Lesson.create(name: "Lemons")
    r = Reading.create(caption: "Today's Reading")
    r2 = Reading.create(caption: "Tomorrow's Reading")
    l.readings << r
    l.readings << r2
    c.lessons << l
    assert_equal c.readings, [r, r2]
  end

  def test_school_name_validation
    s = School.create()
    refute s.valid?
  end

  def test_name_starts_on_ends_on_and_school_id_for_terms_validation
    t = Term.create()
    refute t.valid?
  end
end
