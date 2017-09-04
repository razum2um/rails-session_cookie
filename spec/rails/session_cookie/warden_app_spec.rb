require 'spec_helper'

RSpec.describe Rails::SessionCookie::WardenApp, type: :request, warden: true do
  let(:user) { User.create!(email: 'ad@ad.ad', password: '123123') }
  let(:session_data) { User.serialize_into_session(user) }

  subject { described_class.new(user) }

  describe '#session_cookie' do
    it 'stores everything into session cookie' do
      cookies.merge(subject.session_cookie)

      get '/home'
      user_id_arr, digest = session_data
      expect(response.body).to eq %([["warden.user.user.key",[#{user_id_arr},#{digest.inspect}]]])
    end
  end
end
