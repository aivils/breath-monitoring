require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'api/v2/schema.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V2',
        version: 'v2'
      },
      paths: {},
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT
          },
          apiKeyAuth: {
            type: :apiKey,
            name: :apikey,
            in: :query
          }
        },
        schemas: {}
          .merge(OpenapiSchemas::MEASUREMENT)
          .merge(OpenapiSchemas::VALIDATION_ERRORS)
          .merge(OpenapiSchemas::PASSWORD_RESET)
          .merge(OpenapiSchemas::PROFILE)
          .merge(OpenapiSchemas::UNAUTHORIZED_ERROR)
      }
    }
  }

  config.openapi_format = :yaml
end
