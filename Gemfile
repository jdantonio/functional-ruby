source 'https://rubygems.org'

gemspec

group :development do
  gem 'rake', '~> 10.3.2'
end

group :testing do
  gem 'rspec', '~> 3.0.0'
  gem 'simplecov', '~> 0.9.0', platforms: :mri, require: false
  gem 'coveralls', '~> 0.7.0', require: false
  gem 'codeclimate-test-reporter', group: :test, require: nil
end

group :documentation do
  gem 'countloc', '~> 0.4.0', platforms: :mri, require: false
  gem 'yard', '~> 0.8.7.4', require: false
  gem 'inch', '~> 0.4.6', platforms: :mri, require: false
  gem 'redcarpet', '~> 3.1.2', platforms: :mri # understands github markdown
end
