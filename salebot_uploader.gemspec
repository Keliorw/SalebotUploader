require File.expand_path('lib/SalebotUploader/version', __dir__)

Gem::Specification.new do |spec|
  spec.name                  = 'salebot_uploader'
  spec.version               = SalebotUploader::VERSION
  spec.authors               = ['Aleksey Gudkow']
  spec.email                 = ['alekseygudkou@gmail.com']
  spec.summary               = 'Library for uploader file.'
  spec.description           = 'Library for uploader file from Salebot.'
  spec.homepage              = 'https://github.com/Keliorw/salebot_uploader'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.5'

  spec.files = Dir['README.md', 'LICENSE',
                   'CHANGELOG.md', 'lib/**/*.rb',
                   'lib/**/*.rake',
                   'salebot_uploader.gemspec', '.github/*.md',
                   'Gemfile', 'Rakefile']
  spec.extra_rdoc_files = ['README.md']
  spec.require_paths    = ['lib']
end