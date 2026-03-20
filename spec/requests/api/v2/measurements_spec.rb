require 'rails_helper'
require 'warden/jwt_auth'

RSpec.describe 'Api::V2::Measurements', type: :request do
  let(:user)  { create(:user) }
  let(:admin) { create(:user, :admin) }

  let!(:measurement1) do
    create(
      :measurement,
      user: user,
      code: 'M-001',
      data: "0.0 1\n1.0 2\n2.0 NaN",
      created_at: 2.days.ago
    )
  end

  let!(:measurement2) do
    create(
      :measurement,
      user: user,
      code: 'M-002',
      data: "0.0 5\n1.0 6",
      created_at: 1.day.ago
    )
  end

  def jwt_headers_for(api_user)
    payload = { 'sub' => api_user.id, 'scp' => 'user' }
    token = Warden::JWTAuth::UserEncoder.new.call(api_user, :user, nil).first

    {
      'Authorization' => "Bearer #{token}",
      'Accept' => 'application/json'
    }
  end

  def apikey_params_for(api_user)
    { apikey: api_user.apikey }
  end

  shared_examples 'authenticated index access' do |auth_type|
    it "returns paginated measurements with meta via #{auth_type}" do
      if auth_type == :jwt
        get '/api/v2/measurements', headers: jwt_headers_for(user)
      else
        get '/api/v2/measurements', params: apikey_params_for(user)
      end

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body).to have_key('data')
      expect(body).to have_key('meta')
      expect(body['data'].size).to eq(2)

      expect(body['data'].first['id']).to eq(measurement2.id)
      expect(body['data'].second['id']).to eq(measurement1.id)

      expect(body['data'].first['data_parsed']).to eq([
        [0.0, 5.0],
        [1.0, 6.0]
      ])

      expect(body['data'].second['data_parsed']).to eq([
        [0.0, 1.0],
        [1.0, 2.0],
        [2.0, 0.0]
      ])

      expect(body['meta']).to include(
        'limit_value' => 20,
        'total_pages' => 1,
        'current_page' => 1,
        'next_page' => nil
      )
    end
  end

  describe 'authentication' do
    it 'returns unauthorized without jwt or apikey' do
      get '/api/v2/measurements'

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to eq(
        'error' => 'This is not an authorized request.'
      )
    end
  end

  describe 'GET /api/v2/measurements' do
    include_examples 'authenticated index access', :jwt
    include_examples 'authenticated index access', :apikey

    it 'respects per_page param via jwt' do
      get '/api/v2/measurements',
          params: { per_page: 1 },
          headers: jwt_headers_for(user)

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['data'].size).to eq(1)
      expect(body['meta']['limit_value']).to eq(1)
      expect(body['meta']['total_pages']).to eq(2)
      expect(body['meta']['current_page']).to eq(1)
      expect(body['meta']['next_page']).to eq(2)
    end

    it 'filters by ransack query via apikey' do
      get '/api/v2/measurements',
          params: apikey_params_for(user).merge(q: { id_eq: measurement1.id })

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['data'].size).to eq(1)
      expect(body['data'].first['id']).to eq(measurement1.id)
    end
  end

  describe 'GET /api/v2/measurements/:id' do
    it 'returns the measurement with parsed data via jwt' do
      get "/api/v2/measurements/#{measurement1.id}", headers: jwt_headers_for(user)

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['id']).to eq(measurement1.id)
      expect(body['data_parsed']).to eq([
        [0.0, 1.0],
        [1.0, 2.0],
        [2.0, 0.0]
      ])
    end

    it 'returns the measurement with parsed data via apikey' do
      get "/api/v2/measurements/#{measurement1.id}", params: apikey_params_for(user)

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['id']).to eq(measurement1.id)
    end
  end

  describe 'PATCH /api/v2/measurements/:id' do
    let(:data_window_start) { 1.4 }
    let(:data_window_end)   { 2.5 }

    it 'updates only client-editable fields via jwt' do
      patch "/api/v2/measurements/#{measurement1.id}",
            params: {
              measurement: {
                data_window_start: data_window_start,
                data_window_end: data_window_end,
                processed: true
              }
            },
            headers: jwt_headers_for(user)

      expect(response).to have_http_status(:no_content)

      measurement1.reload
      expect(measurement1.data_window_start).to eq(data_window_start)
      expect(measurement1.data_window_end).to eq(data_window_end)
      expect(measurement1.processed).not_to eq(true)
    end
  end

  describe 'PATCH /api/v2/measurements/:id/review' do
    it 'updates admin-editable fields via jwt' do
      patch "/api/v2/measurements/#{measurement1.id}/review",
            params: {
              measurement: {
                processed: true,
                c19_probability: 11,
                spi_score: 7,
                asdi_score: 42,
                data_window_start: Time.zone.now
              }
            },
            headers: jwt_headers_for(admin)

      expect(response).to have_http_status(:no_content)

      measurement1.reload
      expect(measurement1.processed).to eq(true)
      expect(measurement1.c19_probability.to_f).to eq(11)
      expect(measurement1.spi_score.to_f).to eq(7)
      expect(measurement1.asdi_score.to_f).to eq(42)
      expect(measurement1.data_window_start).to be_nil
    end

    it 'updates admin-editable fields via apikey' do
      patch "/api/v2/measurements/#{measurement1.id}/review",
            params: apikey_params_for(admin).merge(
              measurement: {
                processed: true,
                c19_probability: 91,
                spi_score: 8,
                asdi_score: 50
              }
            )

      expect(response).to have_http_status(:no_content)

      measurement1.reload
      expect(measurement1.processed).to eq(true)
      expect(measurement1.c19_probability.to_f).to eq(91)
      expect(measurement1.spi_score.to_f).to eq(8)
      expect(measurement1.asdi_score.to_f).to eq(50)
    end
  end

  describe 'POST /api/v2/measurements' do
    let(:uploaded_file) do
      tempfile = Tempfile.new(['measurement', '.txt'])
      tempfile.write("0.0 10\n1.0 20\n2.0 NaN")
      tempfile.rewind

      Rack::Test::UploadedFile.new(tempfile.path, 'text/plain')
    end

    it 'creates a measurement for current api user via jwt' do
      expect do
        post '/api/v2/measurements',
             params: {
               measurement: {
                 data_file: uploaded_file,
                 code: 'ABC123'
               }
             },
             headers: jwt_headers_for(user)
      end.to change(Measurement, :count).by(1)

      expect(response).to be_successful

      created = Measurement.order(:created_at).last
      expect(created.user_id).to eq(user.id)
      expect(created.code).to eq('ABC123')
      expect(created.data).to eq("0.0 10\n1.0 20\n2.0 NaN")
    end

    it 'creates a measurement for current api user via apikey' do
      expect do
        post '/api/v2/measurements',
             params: apikey_params_for(user).merge(
               measurement: {
                 data_file: uploaded_file,
                 code: 'XYZ999'
               }
             )
      end.to change(Measurement, :count).by(1)

      expect(response).to be_successful

      created = Measurement.order(:created_at).last
      expect(created.user_id).to eq(user.id)
      expect(created.code).to eq('XYZ999')
    end
  end
end
