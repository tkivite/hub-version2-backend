require 'rails_helper'

RSpec.describe Role, type: :model do
  # it { should belong_to(:user) }
  it { should have_many(:assignments) }
  it { should have_many(:users).through(:assignments) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
