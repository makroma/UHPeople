require 'rails_helper'

RSpec.describe Hashtag do
  context 'chat page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      visit "/login/#{user.id}"
      visit hashtag_path(hashtag.tag)

      click_link 'Join'
    end

    it 'has send button' do
      expect(page).to have_content 'Send'
    end

    context 'messages' do
      before :each do
        FactoryGirl.create(:message, user: user, hashtag: hashtag)
        visit hashtag_path(hashtag.tag)
      end

      it 'have content' do
        expect(page).to have_content 'Hello World!'
      end

      it 'have a thumbnail' do
        expect(find('.avatar-45')).to have_content ''
      end
    end

    it 'can send a message', js: true do
      fill_in('input-text', with: 'Hello world!')
      click_button('Send')

      expect(page).to have_content('Hello world!')
    end
  end
end
