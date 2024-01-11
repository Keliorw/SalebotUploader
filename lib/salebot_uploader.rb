require 'fileutils'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/class/attribute'
require 'active_support/concern'

module SalebotUploader
  class << self
    attr_accessor :root, :base_path
    attr_writer :tmp_path

    def configure(&block)
      SalebotUploader::Uploader::Base.configure(&block)
    end

    def clean_cached_files!(seconds=60*60*24)
      SalebotUploader::Uploader::Base.clean_cached_files!(seconds)
    end

    def tmp_path
      @tmp_path ||= File.expand_path(File.join('..', 'tmp'), root)
    end
  end

end

if defined?(Rails)
  module SalebotUploader
    class Railtie < Rails::Railtie
      initializer 'salebot_uploader.setup_paths' do |app|
        SalebotUploader.root = Rails.root.join(Rails.public_path).to_s
        SalebotUploader.base_path = ENV['RAILS_RELATIVE_URL_ROOT']
        available_locales = Array(app.config.i18n.available_locales || [])
        if available_locales.blank? || available_locales.include?(:en)
          I18n.load_path.prepend(File.join(File.dirname(__FILE__), 'salebot_uploader', 'locale', 'en.yml'))
        end
      end

      initializer 'salebot_uploader.active_record' do
        ActiveSupport.on_load :active_record do
          require 'salebot_uploader/orm/activerecord'
        end
      end

      config.before_eager_load do
        SalebotUploader::Storage::Fog.eager_load
      end
    end
  end
end

require 'salebot_uploader/utilities'
require 'salebot_uploader/error'
require 'salebot_uploader/sanitized_file'
require 'salebot_uploader/mounter'
require 'salebot_uploader/mount'
require 'salebot_uploader/processing'
require 'salebot_uploader/version'
require 'salebot_uploader/storage'
require 'salebot_uploader/uploader'
require 'salebot_uploader/compatibility/paperclip'
require 'salebot_uploader/test/matchers'
