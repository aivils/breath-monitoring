module OpenapiSchemas
  VALIDATION_ERRORS = {
    ValidationErrors: {
      type: :object,
      properties: {
        errors: {
          type: :array,
          items: { type: :string }
        }
      },
      required: ['errors']
    }
  }.freeze
end

