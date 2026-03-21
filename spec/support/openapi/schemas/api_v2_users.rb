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
            code: { type: :string, nullable: true },
            display_time: { type: :integer, enum: [30, 60, 120] },
            record_mode: { type: :string, enum: %w[default limited_120sec] },
            voice_control: { type: :boolean },
            frames_per_second: { type: :string, enum: %w[15 30 60] },
            trend_base64: { type: :string, nullable: true },
            trend_filename: { type: :string, nullable: true },
            trend_content_type: { type: :string, nullable: true }
          }
        }
      },
      required: ['profile']
    }
  }.freeze
end
