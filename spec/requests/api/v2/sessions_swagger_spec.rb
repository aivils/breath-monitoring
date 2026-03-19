require 'swagger_helper'

RSpec.describe 'API V2 Sessions', type: :request do
  path '/api/v2/login' do
    post 'Login' do
      tags 'Sessions'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string }
            },
            required: %w[email password]
          }
        },
        required: ['user']
      }

      response '200', 'successful login' do
        let!(:user) do
          create(:user,
                 email: 'test@example.com',
                 password: 'Password123!',
                 password_confirmation: 'Password123!')
        end

        let(:credentials) do
          {
            user: {
              email: user.email,
              password: 'Password123!'
            }
          }
        end

        schema type: :object,
               properties: {
                 message: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string }
                   },
                   required: %w[id email]
                 }
               },
               required: %w[message user]

        run_test!
      end

      response '401', 'unauthorized' do
        let(:credentials) do
          {
            user: {
              email: 'missing@example.com',
              password: 'WrongPassword!'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v2/logout' do
    delete 'Logout' do
      tags 'Sessions'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :Authorization, in: :header, schema: {
        type: :string
      }, required: true

      response '200', 'successful logout' do
        let!(:user) do
          create(:user,
                 email: 'test@example.com',
                 password: 'Password123!',
                 password_confirmation: 'Password123!')
        end

        let(:Authorization) do
          post '/api/v2/login', params: {
            user: {
              email: user.email,
              password: 'Password123!'
            }
          }, as: :json

          response.headers['Authorization']
        end

        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: ['message']

        run_test!
      end
    end
  end
end
