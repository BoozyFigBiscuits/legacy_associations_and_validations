# Legacy Associations and Validations

## Description
A database to help schools organize courses, instructors, students and more. Users can modify the the database and add new information, or retrieve details from previous terms. 

## Objectives

* To modify an existing database and dependent files. 
* Utilize TDD to add functionality and make sure it's functioning.
* Resolve merge conflicts. 

##Usage
```ruby
    L = Lesson.create(name: "Lemons")
    ICA = Assignment.create(name: "Apples")
    L.in_class_assignment = ICA
```
The database can keep track of a lesson's in-class assignments. 
