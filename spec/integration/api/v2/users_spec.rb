require 'swagger_helper'

RSpec.describe 'API V2 Users', type: :request do
  path '/api/v2/users/{id}/profile' do
    get 'Show user profile' do
      tags 'Users'
      produces 'application/json'
      security [{ apiKeyAuth: [] }, { bearerAuth: [] }]

      parameter name: :id, in: :path, type: :integer
      parameter name: :apikey, in: :query, type: :string, required: false

      response '200', 'profile found' do
        schema '$ref' => '#/components/schemas/api_v2_user_profile_response'

        let(:user) { create(:user, :admin, :with_profile, apikey: "secret123") }
        let!(:profile) { user.profile }
        let(:id) { user.id }
        let(:apikey) { user.apikey }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/unauthorized_error'

        let(:user) { create(:user) }
        let!(:profile) { user.profile }
        let(:id) { user.id }

        run_test!
      end
    end
  end

  path '/api/v2/users/{id}/update_profile' do
    patch 'Update user profile' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ apiKeyAuth: [] }, { bearerAuth: [] }]

      parameter name: :id, in: :path, type: :integer
      parameter name: :apikey, in: :query, type: :string, required: false
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/api_v2_user_profile_update' }

      response '200', 'profile updated' do
        schema '$ref' => '#/components/schemas/api_v2_user_profile_response'

        let(:user) { create(:user, :admin, :with_profile, apikey: "secret123") }
        let!(:profile) { user.profile }
        let(:id) { user.id }
        let(:apikey) { user.apikey }
        let(:params) do
          {
            "user/profile": {
              code: 'new-code',
              display_time: 60,
              record_mode: 'default',
              voice_control: true,
              frames_per_second: '30'
            }
          }
        end

        run_test!
      end

      response '200', 'profile updated with trend upload' do
        schema '$ref' => '#/components/schemas/api_v2_user_profile_response'

        let(:user) { create(:user, :admin, :with_profile, apikey: "secret123") }
        let!(:profile) { user.profile }
        let(:id) { user.id }
        let(:apikey) { user.apikey }
        let(:params) do
          {
            "user/profile": {
              trend_filename: 'trend.png',
              trend_content_type: 'image/png',
              trend_base64: Base64.strict_encode64(
                File.binread(Rails.root.join('spec/fixtures/files/trend.png'))
              )
            }
          }
        end

        run_test!
      end

      response '422', 'invalid base64' do
        schema '$ref' => '#/components/schemas/ValidationErrors'

        let(:user) { create(:user, :admin, :with_profile, apikey: "secret123") }
        let!(:profile) { user.profile }
        let(:id) { user.id }
        let(:apikey) { user.apikey }
        let(:params) do
          {
            "user/profile": {
              trend_filename: 'trend.png',
              trend_content_type: 'image/png',
              trend_base64: 'not-valid-base64!!!'
            }
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/unauthorized_error'

        let(:user) { create(:user) }
        let!(:profile) { user.profile }
        let(:id) { user.id }
        let(:params) do
          {
            "user/profile": {
              code: 'new-code'
            }
          }
        end

        run_test!
      end
    end
  end
end
