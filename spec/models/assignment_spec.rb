require 'rails_helper'

RSpec.describe Assignment, type: :model do  
  describe 'Associations' do    
    it { should belong_to(:user) }
    it { should belong_to(:role) }
  end
end
