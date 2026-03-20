require 'swagger_helper'

RSpec.describe 'API V2 Profiles', type: :request do
  path '/api/v2/profile' do
    get 'Show current user profile' do
      tags 'Profiles'
      produces 'application/json'
      security [{ bearerAuth: [] }, { apiKeyAuth: [] }]

      parameter name: :apikey, in: :query, type: :string, required: false

      response '200', 'profile found (apikey)' do
        let!(:user) { create(:user, :with_profile, apikey: 'test-api-key') }
        let(:apikey) { user.apikey }

        schema '$ref' => '#/components/schemas/profile_response'

        run_test!
      end

      response '200', 'profile found (jwt)' do
        let(:jwt_user) { create(:user, :with_profile) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(jwt_user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }

        schema '$ref' => '#/components/schemas/profile_response'

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/unauthorized_error'
        run_test!
      end
    end

    patch 'Update current user profile' do
      tags 'Profiles'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }, { apiKeyAuth: [] }]

      parameter name: :apikey, in: :query, type: :string, required: false
      parameter name: :profile, in: :body, schema: { '$ref' => '#/components/schemas/profile_update' }

      response '200', 'updated (apikey)' do
        let!(:user) { create(:user, :with_profile, apikey: 'test-api-key') }
        let(:apikey) { user.apikey }
        let(:profile) { { profile: { code: 'new-code' } } }

        schema '$ref' => '#/components/schemas/profile_response'

        run_test!
      end

      response '200', 'updated (jwt)' do
        let(:jwt_user) { create(:user, :with_profile) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(jwt_user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }
        let(:profile) { { profile: { code: 'new-code' } } }

        schema '$ref' => '#/components/schemas/profile_response'

        run_test!
      end

      response '422', 'invalid params' do
        let!(:user) { create(:user, :with_profile, apikey: 'test-api-key') }
        let(:apikey) { user.apikey }
        let(:profile) { { profile: { code: 'INVALID CODE!' } } }

        schema '$ref' => '#/components/schemas/ValidationErrors'

        run_test!
      end

      response '401', 'unauthorized' do
        let(:profile) { { profile: { code: 'new-code' } } }

        schema '$ref' => '#/components/schemas/unauthorized_error'

        run_test!
      end
    end
  end

  path '/api/v2/profile/presence' do
    patch 'Update presence (last_seen_at)' do
      tags 'Profiles'
      produces 'application/json'
      security [{ bearerAuth: [] }, { apiKeyAuth: [] }]

      parameter name: :apikey, in: :query, type: :string, required: false

      response '200', 'ok (apikey)' do
        let(:user) { create(:user, :with_profile, apikey: 'test-api-key', last_seen_at: 2.days.ago) }
        let(:apikey) { user.apikey }

        run_test!
      end

      response '200', 'ok (jwt)' do
        let(:jwt_user) { create(:user, :with_profile, last_seen_at: 2.days.ago) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(jwt_user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/unauthorized_error'
        run_test!
      end
    end
  end
end
