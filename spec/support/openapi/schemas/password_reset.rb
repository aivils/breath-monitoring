module OpenapiSchemas
  PASSWORD_RESET = {
    PasswordResetRequest: {
      type: :object,
      properties: {
        user: {
          type: :object,
          properties: {
            email: { type: :string, format: :email }
          },
          required: ['email']
        }
      },
      required: ['user']
    },
    PasswordResetSuccess: {
      type: :object,
      properties: {
        message: { type: :string }
      },
      required: ['message']
    },
  }.freeze
end

