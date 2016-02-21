# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'byebug'

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
    ci = CourseInstructor.create(instructor_id: 10)
    c.course_instructors << ci
    assert_equal [ci], c.course_instructors
    c.destroy
    refute CourseInstructor.where(id: ci.id).empty?
  end

  def test_lessons_with_inclass_assignments
    l = Lesson.create(name: "Lemons")
    ica = Assignment.create(name: "Apples")
    l.in_class_assignment = ica
    assert_equal ica, l.in_class_assignment
  end

  def test_readings_through_lessons
    c = Course.create(name: "Ruby")
    r = Reading.create(caption: "Today's Reading")
    r2 = Reading.create(caption: "Tomorrow's Reading")
    l = Lesson.create(name: "Lemons")
    c.lessons << l
    l.readings << r2
    l.readings << r
    assert_equal [l], c.lessons
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

  def test_associate_terms_and_schools
    a = School.create(name: "Iron Yard")
    b = Term.create(name: "Spring Semester", starts_on: Time.new(2016,12,30).to_date, ends_on: Time.new(2016,12,31).to_date)
    a.terms << b
    assert_equal [b], a.terms
    end

  def test_associate_terms_with_courses_do_not_destroy_dependents
    a = Term.create(name: "Spring Semester", starts_on: Time.new(2016,12,30).to_date, ends_on: Time.new(2016,12,31).to_date)
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
    b = Course.create(name: "Ruby on Rails", course_code: "ABC123")
    c = Term.create(name: "Spring Semester")
    a.terms << c
    c.courses << b
    assert_equal [c], a.terms
  end

  def test_lessons_have_names
    a = Lesson.create(course_id: 123)
    refute a.valid?
  end

  def test_readings_have_order_number_lesson_id_url
    a = Reading.create(caption: "blah")
    refute a.valid?
  end

  def test_validate_specific_reading_url
    a = Reading.create(order_number: 123, lesson_id: 456, url: "www.yahoo.com")
    refute a.valid?
  end

  def test_validate_courses_have_course_code_and_name
    a = Course.create(color: "Figgy")
    refute a.valid?
  end

  def test_validate_course_code_unique_within_term_id
    a = Course.create(term_id: 1, course_code: 2)
    b = Course.create(term_id: 1, course_code: 2)
    refute b.valid?
  end

  def test_validate_course_code_with_regex
    a = Course.create(course_code: "123ABC", name: "Ruby on Rails")
    refute a.valid?
  end

end
