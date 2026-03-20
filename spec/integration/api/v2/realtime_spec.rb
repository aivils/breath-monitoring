require 'swagger_helper'

RSpec.describe 'API V2 Realtime', type: :request do
  path '/api/v2/realtime' do
    get 'Get ActionCable connection info' do
      tags 'Realtime'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :Authorization, in: :header, schema: {
        type: :string
      }, required: false, description: 'Bearer token'

      response '200', 'realtime connection info returned' do
        schema type: :object,
               required: ['cable_url', 'identifier'],
               properties: {
                 cable_url: { type: :string, example: 'wss://example.com/cable' },
                 identifier: {
                   type: :object,
                   required: ['channel', 'id'],
                   properties: {
                     channel: { type: :string, example: 'MeasurementChannel' },
                     id: { type: :integer, example: 42 }
                   }
                 }
               }

        let(:user) { create(:user) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }

        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'This is not an authorized request.' }
               }

        let(:Authorization) { 'Bearer invalid-token' }

        run_test!
      end
    end
  end
end
