# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Role::ROLES.each do |name|
  Role.where(name: name).first_or_create
end

role = Role.find_by(name: "Admin")
user = User.where(email: 'admin@admin.com').first_or_initialize
if user.new_record?
  user.role_ids = [role.id]
  user.password = '12345678'
  user.password_confirmation = '12345678'
  user.save
end

