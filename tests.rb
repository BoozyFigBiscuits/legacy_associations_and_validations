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
    l = Lesson.create(name: "Lemons")
    ica = Assignment.create(name: "Apples")
    l.in_class_assignment = ica
    assert_equal ica, l.in_class_assignment
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

  def test_user_first_name_last_name_and_email_validation
    u = User.create()
    refute u.valid?
  end

  def test_user_email_is_unique
    u = User.create(first_name: "Damian", last_name: "House", email: "damianhouse@gmail.com")
    u2 = User.create(first_name: "Damian", last_name: "House", email: "damianhouse@gmail.com")
    refute u2.valid?
  end

  def test_validates_user_email_in_correct_form
    u = User.create(first_name: "Damian", last_name: "House", email: "damianhouse@gmail")
    refute u.valid?
  end

  def test_validates_user_photo_url_is_in_correct_format
    u = User.create(first_name: "Lyly", last_name: "Galarza", email: "lylygalarza@gmail.com", photo_url: "www.facebook.com")
    refute u.valid?
  end

  def test_validates_assignments_have_course_id_name_and_percent_of_grade
    a = Assignment.create(name: "Apples")
    refute a.valid?
  end

  def test_validates_assignments_have_unique_name_per_course_id

    a = Assignment.create(name: "Apples", course_id: 21, percent_of_grade: 100)
    a2 = Assignment.create(name: "Apples", course_id: 21, percent_of_grade: 100)
    a3 = Assignment.create(name: "Apples", course_id: 30, percent_of_grade: 100)
    refute a2.valid?
    assert a3.valid?
  end
end
