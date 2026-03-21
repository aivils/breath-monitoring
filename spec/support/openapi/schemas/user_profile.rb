module OpenapiSchemas
  PROFILE = {
    'user_profile': {
      type: :object,
      properties: {
        id: { type: :integer },
        user_id: { type: :integer },
        code: { type: :string, nullable: true },
        display_time: { type: :integer, enum: [30, 60, 120] },
        record_mode: { type: :string, enum: %w[default limited_120sec] },
        voice_control: { type: :boolean },
        frames_per_second: { type: :string, enum: %w[15 30 60] },
        trend_url: { type: :string, nullable: true, format: :uri },
        created_at: { type: :string, format: 'date-time' },
        updated_at: { type: :string, format: 'date-time' }
      },
      required: %w[
        id
        user_id
        display_time
        record_mode
        voice_control
        frames_per_second
        created_at
        updated_at
      ]
    },

    profile_response: {
      type: :object,
      properties: {
        'user/profile': { '$ref' => '#/components/schemas/user_profile' }
      },
      required: ['user/profile']
    },

    profile_update: {
      type: :object,
      properties: {
        profile: {
          type: :object,
          properties: {
            code: { type: :string, nullable: true }
          },
          required: ['code']
        }
      },
      required: ['profile']
    }
  }.freeze
end
