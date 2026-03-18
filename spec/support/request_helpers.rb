module RequestHelpers
  def json
    response.body.present? ? JSON.parse(response.body) : {}
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
