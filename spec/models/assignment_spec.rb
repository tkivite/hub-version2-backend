require 'rails_helper'

RSpec.describe Assignment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
  it { should belong_to(:user) }
  it { should belong_to(:role) }
end
