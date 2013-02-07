Gem::Specification.new do |s|
  s.name = 'cta-api'
  s.version = '1.0.0'
  s.author = 'Frank Bonetti'
  s.date = '2013-02-02'

  s.license = 'MIT'
  s.platform = Gem::Platform::RUBY

  s.description = 'An easy way to access the Chicago Transit Authority API via the Ruby programming language'
  s.summary = 'An easy way to access the Chicago Transit Authority API via the Ruby programming language'
  s.email = 'frank.r.bonetti@gmail.com'

  s.require_paths = ['lib']
  s.files = Dir.glob("**/*").reject { |x| File.directory?(x) }
  s.add_dependency('nokogiri', '>= 1.5.6')
end