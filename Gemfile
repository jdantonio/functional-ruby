source 'https://rubygems.org'

gemspec

group :development do
  gem 'rake', '~> 12.3.0'
end

group :testing do
  gem 'rspec', '~> 3.7.0'
  gem 'simplecov', '~> 0.14.1', platforms: :mri, require: false
  gem 'coveralls', '~> 0.8.21', require: false
end

group :documentation do
  gem 'countloc', '~> 0.4.0', platforms: :mri, require: false
  gem 'yard', '~> 0.9.12', require: false
  gem 'redcarpet', '~> 3.4.0', platforms: :mri # understands github markdown
end
