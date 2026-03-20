require 'rails_helper'

RSpec.describe 'API V2 Users Passwords', type: :request do
  path '/api/v2/password' do
    post 'Password reset is unavailable' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :payload,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    user: {
                      type: :object,
                      properties: {
                        email: { type: :string, format: :email }
                      }
                    }
                  }
                }

      let(:payload) { { user: { email: 'user@example.com' } } }

      response '501', 'not implemented' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error']

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['error']).to eq('Password reset is not available.')
        end
      end
    end
  end
end
