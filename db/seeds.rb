# frozen_string_literal: true

partner = Partner.find_by(name: 'Lipalater-HQ')
unless partner.present?
  partner = Partner.create!(
    name: 'Lipalater-HQ',
    year_of_incorporation: '2014',
    speciality: 'HQ',
    location: 'Nairobi'
  )
  # dev_user.super_user!
  p "Partner created: #{partner.name}"
end

store = Store.find_by(name: 'Lipalater-Nairobi')
unless store.present?
  store = Store.create!(
    name: 'Lipalater-HQ',
    partner_id: partner.id,
    store_key: 'lipalater-nairobi',
    country: 'Kenya'
  )
  # dev_user.super_user!
  p "Store created: #{store.name}"
end

dev_role = Role.find_by(name: 'Developer')
permissions = '[ user:create,user:list,user:show,user:update,role:create,role:list,role:show,role:update,assignment:list]'
unless dev_role.present?
  dev_role = Role.create!(
    name: 'Developer',
    permissions: permissions,
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
    status: 1,
    store_id: store.id
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
  ['Guest', 0, 1],
  ['Sales', 0, 1],
  ['Finance', 0, 1],
  ['BranchManager', 0, 0],
  ['StoreManager', 0, 0],
  ['ACManager', 0, 1],
  ['BDManager', 0, 1],
  ['Executive', 0, 1]
]
roles_list.each_with_index do |role, num|
  Role.create!(name: role[0], created_by: dev_user.id, rank: (num + 1), role_type: role[2])
end

sale = Sale.find_by(external_id: 'e1814f76-fdc5-442d-a9a2-47b2559eda9')
permissions = '[ user:create,user:list,user:show,user:update,role:create,role:list,role:show,role:update,assignment:list]'
unless sale.present?
  Sale.create!(
    customer_names:"Jamie Bayer",
    customer_email:"cassey@mcclure.com",
    customer_phone_number:"719840515",
    customer_id_number:"9804194429086",
    buying_price:"8000.0",
    approved_amount:"8000.0",
    interest_rate:"4.2",
    repayment_period:"12",
    item:"tablet",
    store: store.store_key,
    item_type:"ASUS",
    pick_up_option:"delivery",
    external_id:"e1814f76-fdc5-442d-a9a2-47b2559eda9",
    released_item_id:"e1814f76-fdc5-442d-a9a2-47b2559eda9",
    item_topup_amount:0.0,
    customer_limit:303086.0,
    customer_country:"KE")
  end
