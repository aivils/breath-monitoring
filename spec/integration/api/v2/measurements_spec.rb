require 'swagger_helper'
require 'warden/jwt_auth'

RSpec.describe 'Api::V2::Measurements API', swagger_doc: 'api/v2/schema.yaml', type: :request do
  let(:user)  { create(:user) }
  let(:admin) { create(:user, :admin) }

  def bearer_token_for(api_user)
    Warden::JWTAuth::UserEncoder.new.call(api_user, :user, nil).first
  end

  path '/api/v2/measurements' do
    get 'List measurements' do
      tags 'Measurements'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: false,
                description: 'Bearer JWT token. Example: Bearer eyJ...'
      parameter name: :apikey, in: :query, type: :string, required: false,
                description: 'API key alternative authentication'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      parameter name: :q,
              in: :query,
              style: :deepObject,
              explode: true,
              required: false,
              description: 'Ransack filters and sorting. Example: q[id_eq]=1&q[processed_eq]=true&q[s]=created_at desc',
              schema: {
                type: :object,
                properties: {
                  id_eq: { type: :integer, example: 1 },
                  user_id_eq: { type: :integer, example: 10 },
                  code_eq: { type: :string, example: 'ABC123' },
                  code_cont: { type: :string, example: 'ABC' },
                  approved_eq: { type: :boolean, example: true },
                  processed_eq: { type: :boolean, example: true },
                  c19_host_eq: { type: :boolean, example: false },
                  created_at_gteq: { type: :string, format: :'date-time', example: '2026-03-01T00:00:00Z' },
                  created_at_lteq: { type: :string, format: :'date-time', example: '2026-03-31T23:59:59Z' },
                  s: {
                    type: :string,
                    example: 'created_at desc',
                    enum: ['created_at desc', 'created_at asc']
                  }
                }
              }

      response '200', 'measurements returned with jwt' do
        schema '$ref' => '#/components/schemas/measurements_index_response'

        let(:Authorization) { "Bearer #{bearer_token_for(user)}" }
        let(:apikey) { nil }

        let!(:measurement1) do
          create(:measurement, user: user, data: "0.0 1\n1.0 2\n2.0 NaN", created_at: 2.days.ago)
        end

        let!(:measurement2) do
          create(:measurement, user: user, data: "0.0 5\n1.0 6", created_at: 1.day.ago)
        end

        run_test!
      end

      response '200', 'measurements returned with apikey' do
        schema '$ref' => '#/components/schemas/measurements_index_response'

        let(:Authorization) { nil }
        let(:apikey) { user.apikey }

        let!(:measurement1) do
          create(:measurement, user: user, data: "0.0 1\n1.0 2\n2.0 NaN", created_at: 2.days.ago)
        end

        let!(:measurement2) do
          create(:measurement, user: user, data: "0.0 5\n1.0 6", created_at: 1.day.ago)
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        let(:apikey) { nil }

        run_test!
      end
    end

    post 'Create measurement' do
      tags 'Measurements'
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: false,
                description: 'Bearer JWT token'
      parameter name: :apikey, in: :query, type: :string, required: false,
                description: 'API key alternative authentication'
      parameter name: :measurement, in: :formData, schema: {
        type: :object,
        properties: {
          data_file: { type: :string, format: :binary },
          code: { type: :string }
        },
        required: %w[data_file]
      }

      response '201', 'measurement created with jwt' do
        let(:Authorization) { "Bearer #{bearer_token_for(user)}" }
        let(:apikey) { nil }
        let(:measurement) do
          {
            data_file: Rack::Test::UploadedFile.new(
              Rails.root.join('spec/fixtures/files/measurement_sample.txt'),
              'text/plain'
            ),
            code: 'ABC123'
          }
        end

        run_test!
      end

      response '201', 'measurement created with apikey' do
        let(:Authorization) { nil }
        let(:apikey) { user.apikey }
        let(:measurement) do
          {
            data_file: Rack::Test::UploadedFile.new(
              Rails.root.join('spec/fixtures/files/measurement_sample.txt'),
              'text/plain'
            ),
            code: 'APIKEY123'
          }
        end

        run_test!
      end
    end
  end

  path '/api/v2/measurements/{id}' do
    get 'Show measurement' do
      tags 'Measurements'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: false
      parameter name: :apikey, in: :query, type: :string, required: false
      parameter name: :id, in: :path, type: :integer

      response '200', 'measurement found' do
        schema '$ref' => '#/components/schemas/measurement'

        let(:Authorization) { "Bearer #{bearer_token_for(user)}" }
        let(:apikey) { nil }
        let(:id) { create(:measurement, user: user, data: "0.0 1\n1.0 2\n2.0 NaN").id }

        run_test!
      end
    end

    patch 'Update measurement client fields' do
      tags 'Measurements'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: false
      parameter name: :apikey, in: :query, type: :string, required: false
      parameter name: :id, in: :path, type: :integer
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          measurement: {
            type: :object,
            properties: {
              data_window_start: { type: :string, format: :'date-time' },
              data_window_end: { type: :string, format: :'date-time' }
            }
          }
        },
        required: %w[measurement]
      }

      response '204', 'measurement updated' do
        let(:Authorization) { "Bearer #{bearer_token_for(user)}" }
        let(:apikey) { nil }
        let(:resource) { create(:measurement, user: user) }
        let(:id) { resource.id }
        let(:payload) do
          {
            measurement: {
              data_window_start: '2026-03-10T10:00:00Z',
              data_window_end: '2026-03-10T11:00:00Z'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v2/measurements/{id}/review' do
    patch 'Review measurement admin fields' do
      tags 'Measurements'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: false
      parameter name: :apikey, in: :query, type: :string, required: false
      parameter name: :id, in: :path, type: :integer
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          measurement: {
            type: :object,
            properties: {
              processed: { type: :boolean },
              c19_probability: { type: :number, format: :float },
              spi_score: { type: :number, format: :float },
              asdi_score: { type: :number, format: :float }
            }
          }
        },
        required: %w[measurement]
      }

      response '204', 'measurement reviewed' do
        let(:Authorization) { "Bearer #{bearer_token_for(admin)}" }
        let(:apikey) { nil }
        let(:resource) { create(:measurement, user: user) }
        let(:id) { resource.id }
        let(:payload) do
          {
            measurement: {
              processed: true,
              c19_probability: 0.87,
              spi_score: 7.5,
              asdi_score: 42.0
            }
          }
        end

        run_test!
      end
    end
  end
end
