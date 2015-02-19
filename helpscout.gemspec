Gem::Specification.new do |s|
  s.name = 'helpscout'
  s.version = '0.0.6'
  s.authors = ['Daniel LaGrotta']
  s.date = '2015-02-19'
  s.description = ''
  s.files = %w(Gemfile README.markdown Rakefile VERSION helpscout.gemspec lib/helpscout.rb lib/helpscout/client.rb lib/helpscout/models.rb)
  s.homepage = 'http://github.com/soul2197/helpscout'
  s.license = 'MIT'
  s.require_paths = ['lib']
  s.summary = 'HelpScout API Wrapper'

  s.add_dependency 'httparty', '>= 0'

  s.add_development_dependency 'bundler', '>= 1.2.3'
  s.add_development_dependency 'jeweler', '~> 1.8.4'
  s.add_development_dependency 'simplecov', '>= 0'
  s.add_development_dependency 'reek', '~> 1.2.8'
  s.add_development_dependency 'rdoc', '>= 0'
end
