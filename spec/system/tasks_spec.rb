require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task) }


  describe 'ログイン前' do 
    describe 'ページ変更確認' do 
      context 'タスク新規登録ページにアクセス' do
        it '新規登録ページにアクセス失敗' do
          visit new_task_path
          expect(page).to have_content('Login required')
          expect(current_path).to eq login_path
        end
      end

      context 'タスク詳細ページアクセス' do 
        it 'タスク詳細ページアクセス失敗' do 
          visit edit_task_path(task)
          expect(page).to have_content('Login required')
          expect(current_path).to eq login_path
        end
      end

      context 'タスク編集ページ' do
        it 'タスク編集ページにアクセス失敗' do 
          visit edit_task_path(task)
          expect(page).to have_content('Login require')
          expect(current_path).to eq login_path
        end
      end

      context 'タスクの詳細ページにアクセス' do
        it 'タスクの詳細情報が表示される' do
          task_list = create_list(:task, 3)
          visit tasks_path
          expect(page).to have_content task_list[0].title
          expect(page).to have_content task_list[1].title
          expect(page).to have_content task_list[2].title
          expect(current_path).to eq tasks_path
        end
      end
    end
  end

  describe 'ログイン後' do
    before {login_as(user) }

    describe 'タスク新規登録' do
      context 'フォームの入力値が正常' do
        it 'タスクの新規作成が成功する' do
          visit new_task_path
          fill_in 'Title', with: 'create_title'
          fill_in 'Content', with: 'content test'
          select 'done', from: 'Status'
          fill_in 'Deadline', with: DateTime.new(2020,6,27,16,10)
          click_button 'Create Task'
          expect(page).to have_content ('Task was successfully created.')
          expect(current_path).to eq '/tasks/1'
        end
      end
      
      context 'タスク未入力' do
        it 'タスク新規登録が失敗' do
          visit new_task_path
          fill_in 'Title', with: ' '
          fill_in 'Content', with: 'content test'
          click_button 'Create Task'
          expect(page).to have_content ('1 error prohibited this task from being saved')
          expect(page).to have_content("Title can't be blank")
        end
      end

      context '登録済タスク編集' do
        it 'タスク編集失敗' do
          visit new_task_path
          test_task = create(:task)
          fill_in 'Title', with: test_task.title
          fill_in 'Content', with: 'test_content'
          click_button 'Create Task'
          expect(page).to have_content ('1 error prohibited this task from being saved')
          expect(page).to have_content('Title has already been taken')
          expect(current_path).to eq tasks_path
        end
      end
    end

    describe 'タスク編集' do

      let(:task) {create(:task, user: user)}

      context 'フォームの入力値が正常' do
        it 'タスク編集が成功' do 
          visit edit_task_path(task)
          fill_in 'Title', with: 'updete_title'
          fill_in 'Content', with: 'update_contet'
          select 'todo', from: 'Status'
          click_button 'Update Task'
          expect(page).to have_content('Task was successfully updated.')
          expect(current_path).to eq '/tasks/1'
        end
      end

      context 'タイトルが未入力' do 
        it 'タスク編集が失敗' do
          visit edit_task_path(task)
          fill_in 'Title', with: ' '
          fill_in 'Content', with: 'test'
          click_button 'Update Task'
          expect(page).to have_content('1 error prohibited this task from being saved:')
          expect(page).to have_content("Title can't be blank")
          expect(current_path).to eq '/tasks/1'
        end
      end
      
      context 'タスク登録済を入力' do
        it 'タイトルが重複で失敗' do
          duplication_title = create(:task, user: user)
          visit edit_task_path(task)
          fill_in 'Title', with: duplication_title.title
          fill_in 'Content', with: 'test'
          click_button 'Update Task'
          expect(page).to have_content('1 error prohibited this task from being saved:')
          expect(page).to have_content('Title has already been taken')
          expect(current_path).to eq '/tasks/2'
        end
      end 
    end

    describe 'タスク削除' do 
      let!(:task) {create(:task, user: user)}

      it 'タスク削除に成功' do 
        visit tasks_path
        click_link 'Destroy'
        expect(page.accept_confirm).to eq 'Are you sure?'
        expect(page).to have_content('Task was successfully destroyed.')
        expect(current_path).to eq tasks_path
       expect(page).not_to have_content task.title
      end
    end
  end
end