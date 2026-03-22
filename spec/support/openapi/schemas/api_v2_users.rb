module OpenapiSchemas
  API_V2_USERS = {
    api_v2_user_profile_response: {
      type: :object,
      properties: {
        'user/profile': { '$ref' => '#/components/schemas/user_profile' }
      },
      required: ['user/profile']
    },

    api_v2_user_profile_update: {
      type: :object,
      properties: {
        profile: {
          type: :object,
          properties: {
            code: {
              type: :string,
              nullable: true,
              description: 'Code (alphanumeric with dashes)'
            },
            display_time: {
              type: :integer,
              enum: [30, 60, 120],
              description: 'Duration in seconds for displaying measurements'
            },
            record_mode: {
              type: :string,
              enum: %w[default limited_120sec],
              description: 'Recording mode configuration'
            },
            voice_control: {
              type: :boolean,
              description: 'Enable or disable voice control'
            },
            frames_per_second: {
              type: :string,
              enum: %w[15 30 60],
              description: 'Video recording frame rate'
            },
            trend_base64: {
              type: :string,
              nullable: true,
              description: 'Base64-encoded image file content'
            },
            trend_filename: {
              type: :string,
              nullable: true,
              description: 'Original file name of the uploaded image'
            },
            trend_content_type: {
              type: :string,
              nullable: true,
              description: 'MIME type of the uploaded image (e.g., image/png)'
            }
          }
        }
      },
      required: ['profile']
    }
  }.freeze
end
