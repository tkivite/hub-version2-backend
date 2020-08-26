# frozen_string_literal: true

dev_role = Role.find_by(name: 'Developer')
unless dev_role.present?
  dev_role = Role.create!(
    name: 'Developer',
    created_by: '0'
  )
  # dev_user.super_user!

  p "Developer role: #{dev_role.name}"
end
dev_user = User.find_by(email: 'devops@lipalater.com')
unless dev_user.present?
  dev_user = User.create!(
    firstname: 'Developer',
    othernames: 'user',
    gender: 'Male',
    mobile: '+254725475051',
    email: 'devops@lipalater.com',
    password: 'Lip@l@t3r!2020',
    created_by: 0,
    last_login_time: '2020-08-25 15:07:49',
    logged_in: false,
    status: '1'
  )
  # dev_user.super_user!

  p "Developer user Email: #{dev_user.email}"
  p "Developer user Password: #{dev_user.password}"

end
dev_assignment = Assignment.where(user_id: dev_user.id, role_id: dev_role.id)
unless dev_assignment.present?
  dev_assignment = Assignment.create!(
    user_id: dev_user.id,
    role_id: dev_role.id
  )
  # dev_user.super_user!
  p "Developer assignment user: #{dev_assignment.user_id}"
  p "Developer assignment role: #{dev_assignment.role_id}"
end
p 'Creating other roles'
roles_list = [

  ['Executive', 0, 1],
  ['BDManager', 0, 1],
  ['ACManager', 0, 1],
  ['StoreManager', 0, 0],
  ['BranchManager', 0, 0],
  ['Finance', 0, 1],
  ['Sales', 0, 1],
  ['Guest', 0, 1]
]
roles_list.each_with_index do |role, num|
  Role.create!(name: role[0], created_by: dev_user.id, rank: num, role_type: role[2])
end