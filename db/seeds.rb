# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


project_list = [
    [ "Team Planner", "Know about your team", "This is a project where we can show all activites of all team" ],
    [ "Horsecount", "Horse Management", "All things of horse is introduced in this project"],
    [ "UDK", "Undiscovered Kitchen","UDK is a consumer project" ]
]


project_list.each do |name, title, description|
  Project.find_or_create_by( name: name, title: title, description: description )
end

developer_list = [
    ["Swawibe","Junior Soft Engineer","2014-08-18","1"],
    ["Shumon","Junior Soft Engineer","2014-06-10","2"],
    ["Rafi","Senior Soft Engineer","2014-08-10","4"],
    ["Tauhid","Junior Soft Engineer","2013-05-10","1"],
    ["Akter","Senior Soft Engineer ","2013-02-01","5"]
]

developer_list.each do |name, designation, joining_date, previous_job_exp|
  Developer.find_or_create_by( name: name, designation: designation, joining_date: joining_date, previous_job_exp: previous_job_exp )
end