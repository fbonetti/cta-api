Gem::Specification.new do |s|
  s.name = 'cta-api'
  s.version = '1.0.1'
  s.author = 'Frank Bonetti'
  s.homepage = 'https://github.com/fbonetti/cta-api'
  s.date = '2013-02-02'

  s.license = 'MIT'
  s.platform = Gem::Platform::RUBY

  s.description = 'An easy way to access the Chicago Transit Authority API via the Ruby programming language'
  s.summary = 'An easy way to access the Chicago Transit Authority API via the Ruby programming language'
  s.email = 'frank.r.bonetti@gmail.com'

  s.require_paths = ['lib']
  s.files = Dir.glob("**/*").reject { |x| File.directory?(x) }
  s.add_dependency('httparty', '>= 0.10.2')
  s.add_dependency('hashie', '>= 2.0.0')
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
end
