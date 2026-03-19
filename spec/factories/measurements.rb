FactoryBot.define do
  factory :measurement do
    association :user
    code { 'CODE123' }
    data { "0.0 1\n1.0 2" }
    processed { false }
    approved { false }
    c19_host { false }
    c19_probability { nil }
    spi_score { nil }
    asdi_score { nil }
    data_window_start { nil }
    data_window_end { nil }
  end
end
