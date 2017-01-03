require 'rails_helper'

describe WebHook, type: :model do
  it { should belong_to(:github_repository) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:url) }
end
