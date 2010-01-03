require 'machinist/active_record'
require 'sham'
require 'faker'

Post.blueprint do
  category { 'Programming' }
  title { Faker::Company.catch_phrase }
  body { Faker::Lorem.paragraphs.join("\n\n") }
  # body { Faker::Lorem.paragraph }
  published { true }
end