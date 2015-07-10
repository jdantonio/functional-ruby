source 'https://rubygems.org'

gemspec

group :development do
  gem 'rake', '~> 10.4.2'
end

group :testing do
  gem 'rspec', '~> 3.3.0'
  gem 'simplecov', '~> 0.10.0', platforms: :mri, require: false
  gem 'coveralls', '~> 0.8.2', require: false
  gem 'codeclimate-test-reporter', '~> 0.4.7', group: :test, require: nil
end

group :documentation do
  gem 'countloc', '~> 0.4.0', platforms: :mri, require: false
  gem 'yard', '~> 0.8.7.6', require: false
  gem 'inch', '~> 0.6.3', platforms: :mri, require: false
  gem 'redcarpet', '~> 3.3.2', platforms: :mri # understands github markdown
end
