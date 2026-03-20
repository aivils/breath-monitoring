require 'rails_helper'

RSpec.describe 'Api::V2::Users::Passwords', type: :request do
  describe 'POST /api/v2/password' do
    it 'returns not implemented' do
      post '/api/v2/password',
           params: { user: { email: 'user@example.com' } },
           headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:not_implemented)

      body = JSON.parse(response.body)
      expect(body['error']).to eq('Password reset is not available.')
    end
  end
end
