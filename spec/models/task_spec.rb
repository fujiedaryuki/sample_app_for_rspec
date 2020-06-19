require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do    
    it 'タイトルが無いと無効' do
      task_without = build(:task, title: "")
      expect(task_without).to be_invalid
      expect(task_without.errors[:title]).to eq ["can't be blank"]
    end

    it 'ステータスなしでは無効' do 
      status_without = build(:task, status: "")
      expect(status_without).to be_invalid
      expect(status_without.errors[:status]).to eq ["can't be blank"]
    end

    it 'タイトルが重複しているため無効' do
      duplicate_title = build(:task, title: create(:task).title)
      expect(duplicate_title).to be_invalid
      expect(duplicate_title.errors[:title]).to eq ["has already been taken"]
    end

    it '別のタイトルでも有効' do 
      task_another_title = build(:task, title: 'test_title')
      expect(task_another_title).to be_valid
    end

  end
end
