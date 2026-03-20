require 'rails_helper'

RSpec.describe Api::V2::Users::ProfilesController, type: :request do
  let(:jwt_user) { create(:user, :with_profile) }
  let(:jwt_token) { Warden::JWTAuth::UserEncoder.new.call(jwt_user, :user, nil).first }
  let(:jwt_headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'GET /api/v2/profile' do
    subject(:make_request) { get '/api/v2/profile', params: params, headers: headers }

    let(:params) { {} }
    let(:headers) { {} }

    context 'when unauthorized' do
      it 'returns unauthorized' do
        make_request

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq(
          'error' => 'This is not an authorized request.'
        )
      end
    end

    context 'when authorized with apikey' do
      let!(:user) { create(:user, :with_profile, apikey: 'test-api-key') }
      let(:profile) { user.profile }
      let(:params) { { apikey: user.apikey } }

      it 'returns profile' do
        make_request

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        result = body["user/profile"]
        expect(result['id']).to eq(profile.id)
        expect(result['user_id']).to eq(user.id)
      end
    end

    context 'when authorized with jwt' do
      let(:profile) { jwt_user.profile }
      let(:headers) { jwt_headers }

      it 'returns profile' do
        make_request

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        result = body["user/profile"]
        expect(result['id']).to eq(profile.id)
        expect(result['user_id']).to eq(jwt_user.id)
      end
    end
  end

  describe 'PATCH /api/v2/profile' do
    subject(:make_request) { patch '/api/v2/profile', params: params, headers: headers }

    let(:headers) { {} }

    context 'when unauthorized' do
      let(:params) do
        {
          profile: {
            code: 'new-code'
          }
        }
      end

      it 'returns unauthorized' do
        make_request

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq(
          'error' => 'This is not an authorized request.'
        )
      end
    end

    context 'when authorized with apikey' do
      let!(:user) { create(:user, :with_profile, apikey: 'test-api-key') }
      let(:profile) { user.profile }

      context 'with valid params' do
        let(:params) do
          {
            apikey: user.apikey,
            profile: {
              code: 'new-code'
            }
          }
        end

        it 'updates profile and returns it' do
          make_request

          expect(response).to have_http_status(:ok)
          expect(profile.reload.code).to eq('new-code')

          body = JSON.parse(response.body)
          result = body["user/profile"]
          expect(result['code']).to eq('new-code')
        end
      end

      context 'with invalid params' do
        before do
          profile.update(code: 'old-code')
        end

        let(:params) do
          {
            apikey: user.apikey,
            profile: {
              code: 'INVALID CODE!'
            }
          }
        end

        it 'returns unprocessable entity' do
          make_request

          expect(response).to have_http_status(:unprocessable_entity)
          expect(profile.reload.code).to eq('old-code')
        end
      end
    end

    context 'when authorized with jwt' do
      let(:headers) { jwt_headers }
      let(:profile) { jwt_user.profile }

      context 'with valid params' do
        let(:params) do
          {
            profile: {
              code: 'new-code'
            }
          }
        end

        it 'updates profile and returns it' do
          make_request

          expect(response).to have_http_status(:ok)
          expect(profile.reload.code).to eq('new-code')

          body = JSON.parse(response.body)
          result = body["user/profile"]
          expect(result['code']).to eq('new-code')
        end
      end

      context 'with invalid params' do
        before do
          profile.update(code: 'old-code')
        end

        let(:params) do
          {
            profile: {
              code: 'INVALID CODE!'
            }
          }
        end

        it 'returns unprocessable entity' do
          make_request

          expect(response).to have_http_status(:unprocessable_entity)
          expect(profile.reload.code).to eq('old-code')
        end
      end
    end
  end

  describe 'PATCH /api/v2/profile/presence' do
    subject(:make_request) { patch '/api/v2/profile/presence', params: params, headers: headers }

    let(:params) { {} }
    let(:headers) { {} }

    context 'when unauthorized' do
      it 'returns unauthorized' do
        make_request

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq(
          'error' => 'This is not an authorized request.'
        )
      end
    end

    context 'when authorized with apikey' do
      let(:user) { create(:user, :with_profile, apikey: 'test-api-key', last_seen_at: 2.days.ago) }
      let(:params) { { apikey: user.apikey } }

      it 'updates last_seen_at and returns ok' do
        expect do
          make_request
        end.to change { user.reload.last_seen_at }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_blank
      end
    end

    context 'when authorized with jwt' do
      let(:headers) { jwt_headers }

      before do
        jwt_user.update!(last_seen_at: 2.days.ago)
      end

      it 'updates last_seen_at and returns ok' do
        expect do
          make_request
        end.to change { jwt_user.reload.last_seen_at }

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_blank
      end
    end
  end
end
