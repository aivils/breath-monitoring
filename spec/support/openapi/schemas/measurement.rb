module OpenapiSchemas
  MEASUREMENT = {
    measurement: {
      type: :object,
      properties: {
        id: { type: :integer },
        user_id: { type: :integer, nullable: true },
        code: { type: :string, nullable: true },
        approved: { type: :boolean, nullable: true },
        processed: { type: :boolean, nullable: true },
        c19_host: { type: :boolean, nullable: true },
        c19_probability: { type: :integer, nullable: true },
        spi_score: { type: :integer, nullable: true },
        asdi_score: { type: :integer, nullable: true },
        data_window_start: { type: :number, format: :float, nullable: true },
        data_window_end: { type: :number, format: :float, nullable: true },
        created_at: { type: :string, format: :'date-time' },
        updated_at: { type: :string, format: :'date-time' },
        data_parsed: {
          type: :array,
          items: {
            type: :array,
            items: { type: :number, format: :float }
          }
        }
      },
      required: %w[id created_at updated_at]
    },
    measurements_index_response: {
      type: :object,
      properties: {
        data: {
          type: :array,
          items: { '$ref' => '#/components/schemas/measurement' }
        },
        meta: {
          type: :object,
          properties: {
            limit_value: { type: :integer },
            total_pages: { type: :integer },
            current_page: { type: :integer },
            next_page: { type: :integer, nullable: true }
          }
        }
      },
      required: %w[data meta]
    },
  }.freeze
end
