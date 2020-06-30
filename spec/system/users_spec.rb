require 'rails_helper'

RSpec.describe "Users", type: :system do

  let(:user) { create(:user) }
   
  describe 'ログイン前' do 
    describe 'ユーザー新規登録'  do
      context 'フォーム入力値が正常' do
        it 'ユーザーの新規登録が成功' do 
          visit sign_up_path
          fill_in 'Email', with: 'user_test@example.com'
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'SignUp'
          expect(page).to have_content ('User was successfully created')
        end
      end

      context 'メールアドレス未入力' do
        it 'ユーザー新規作成は失敗する' do
          user = User.new(email: '',  password: 'password', password_confirmation: 'password')
          visit sign_up_path
          fill_in 'Email', with: ' '
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'SignUp'
          expect(page).to have_content ("Email can't be blan")
        end
      end

      context '登録済のメールアドレスを使用' do 
        it 'ユーザーの新規作成が失敗する' do
          visit sign_up_path
          fill_in 'Email', with: user.email
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'SignUp'
          expect(page).to have_content 'Email has already been taken'
          expect(page).to have_content '1 error prohibited this user from being saved' 
        end
      end
    end

    describe 'マイページ' do 
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit user_path(user)
          expect(page).to have_content('Login required')
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login_as(user) }

    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          visit edit_user_path(user)
          fill_in 'Email', with: 'update@example.com'
          fill_in 'Password', with: 'update_password'
          fill_in 'Password confirmation', with: 'update_password'
          click_button 'Update'
          expect(page).to have_content('User was successfully updated.')
          expect(current_path).to eq user_path(user)
        end
      end

      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          visit edit_user_path(user)
          fill_in 'Email', with: ' '
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
          expect(page).to have_content('1 error prohibited this user from being saved')
          expect(page).to have_content("Email can't be blank")
        end
      end

      context '登録済メールアドレス' do
        it 'ユーザー編集が失敗' do
          visit edit_user_path(user)
          duplication_user = create(:user)
          fill_in 'Email', with: duplication_user.email
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
          expect(page).to have_content('1 error prohibited this user from being saved:')
          expect(page).to have_content('Email has already been taken')
          expect(current_path).to eq user_path(user)
        end
      end

      context '他人ユーザーの編集ページにアクセス' do
        it '編集ページにアクセス失敗' do
          other_user = create(:user)
          visit edit_user_path(other_user)
          expect(page).to have_content('Forbidden access.')
          expect(current_path).to eq user_path(user)
        end
      end
    end

    describe 'マイページ' do 
      context 'タスク作成' do
        it '新規作成が表示されている' do
         create(:task, title:'user_title', status: :todo, user: user)
          visit user_path(user)
          expect(page).to have_content('You have 1 task.')
          expect(page).to have_content('user_title')
          expect(page).to have_content('todo')
          expect(page).to have_content('Show')
          expect(page).to have_content('Edit')
          expect(page).to have_content('Destroy')
        end
      end
    end
  end
end