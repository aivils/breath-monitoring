require 'rails_helper'

RSpec.describe 'Api::V2::Sessions', type: :request do
  let!(:user) do
    create(
      :user,
      email: 'test@example.com',
      password: 'Password123!',
      password_confirmation: 'Password123!'
    )
  end

  describe 'POST /api/v2/login' do
    let(:path) { '/api/v2/login' }

    context 'with valid credentials' do
      let(:params) do
        {
          user: {
            email: user.email,
            password: 'Password123!'
          }
        }
      end

      it 'returns http success' do
        post path, params: params, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'returns user data in json' do
        post path, params: params, as: :json

        expect(json['message']).to eq('Logged in successfully.')
        expect(json['user']).to include(
          'id' => user.id,
          'email' => user.email
        )
      end

      it 'returns jwt token in Authorization header' do
        post path, params: params, as: :json

        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to match(/^Bearer /)
      end
    end

    context 'with invalid password' do
      let(:params) do
        {
          user: {
            email: user.email,
            password: 'WrongPassword!'
          }
        }
      end

      it 'returns unauthorized' do
        post path, params: params, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with unknown email' do
      let(:params) do
        {
          user: {
            email: 'missing@example.com',
            password: 'Password123!'
          }
        }
      end

      it 'returns unauthorized' do
        post path, params: params, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v2/logout' do
    let(:path) { '/api/v2/logout' }

    context 'with valid jwt token' do
      let(:login_params) do
        {
          user: {
            email: user.email,
            password: 'Password123!'
          }
        }
      end

      it 'logs out successfully' do
        post '/api/v2/login', params: login_params, as: :json
        token = response.headers['Authorization']

        delete path, headers: { 'Authorization' => token }, as: :json

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'without token' do
      it 'returns no_content' do
        delete path, as: :json

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
