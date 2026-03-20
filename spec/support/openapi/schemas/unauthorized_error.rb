module OpenapiSchemas
  UNAUTHORIZED_ERROR = {
    unauthorized_error: {
      type: :object,
      properties: {
        error: { type: :string, example: 'This is not an authorized request.' }
      },
      required: ['error']
    }
  }.freeze
end
