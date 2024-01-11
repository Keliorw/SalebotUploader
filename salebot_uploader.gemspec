lib = File.expand_path('lib', __dir__)
$:.unshift lib unless $:.include?(lib)

require 'salebot_uploader/version'

Gem::Specification.new do |spec|
  spec.name                  = 'salebot_uploader'
  spec.version               = SalebotUploader::VERSION

  spec.authors               = ['Aleksey Gudkow']
  spec.email                 = ['alekseygudkou@gmail.com']
  spec.summary               = 'Library for uploader file.'
  spec.description           = 'Library for uploader file from Salebot.'
  spec.extra_rdoc_files      = ['README.md']
  spec.files                 = Dir['{bin,lib}/**/*', 'README.md']
  spec.homepage              = 'https://github.com/Keliorw/salebot_uploader'
  spec.rdoc_options          = ['--main']
  spec.require_paths         = ['lib']
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.5'

  spec.add_dependency 'addressable', '~> 2.6'
  spec.add_dependency 'image_processing', '~> 1.1'
  spec.add_dependency 'marcel', '~> 1.0.0'
  spec.add_dependency 'ssrf_filter', '~> 1.0'
  spec.add_development_dependency 'cucumber', '~> 2.3'
  spec.add_development_dependency 'fog-aws'
  spec.add_development_dependency 'fog-google', ['~> 1.7', '!= 1.12.1']
  spec.add_development_dependency 'fog-local'
  spec.add_development_dependency 'fog-rackspace'
  spec.add_development_dependency 'generator_spec', '>= 0.9.1'
  spec.add_development_dependency 'mini_magick', '>= 3.6.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug' if RUBY_ENGINE != 'jruby'
  spec.add_development_dependency 'rmagick', '>= 2.16' if RUBY_ENGINE != 'jruby'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rspec-retry'
  spec.add_development_dependency 'rubocop', '~> 1.28'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.37'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'webmock'
end