$:.unshift File.expand_path(File.join('..', '..', 'lib'), File.dirname(__FILE__))

require File.join(File.dirname(__FILE__), 'activerecord')

require 'rspec'
require 'salebot_uploader'
require 'webmock/cucumber'

def file_path( *paths )
  File.expand_path(File.join('..', *paths), File.dirname(__FILE__))
end

SalebotUploader.root = file_path('public')

After do
  FileUtils.rm_rf(file_path('public'))
end
