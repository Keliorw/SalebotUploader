require 'salebot_uploader/downloader/base'

module SalebotUploader

  module Uploader
    module Configuration
      extend ActiveSupport::Concern

      included do
        class_attribute :_storage, :_cache_storage, :instance_writer => false

        add_config :root
        add_config :base_path
        add_config :asset_host
        add_config :permissions
        add_config :directory_permissions
        add_config :storage_engines
        add_config :store_dir
        add_config :cache_dir
        add_config :enable_processing
        add_config :ensure_multipart_form
        add_config :delete_tmp_file_after_storage
        add_config :move_to_cache
        add_config :move_to_store
        add_config :remove_previously_stored_files_after_update
        add_config :downloader
        add_config :force_extension

        # fog
        add_deprecated_config :fog_provider
        add_config :fog_attributes
        add_config :fog_credentials
        add_config :fog_directory
        add_config :fog_public
        add_config :fog_authenticated_url_expiration
        add_config :fog_use_ssl_for_aws
        add_config :fog_aws_accelerate

        # Mounting
        add_config :ignore_integrity_errors
        add_config :ignore_processing_errors
        add_config :ignore_download_errors
        add_config :validate_integrity
        add_config :validate_processing
        add_config :validate_download
        add_config :mount_on
        add_config :cache_only
        add_config :download_retry_count
        add_config :download_retry_wait_time
        add_config :skip_ssrf_protection

        # set default values
        reset_config
      end

      module ClassMethods
        def storage(storage = nil)
          case storage
          when Symbol
            if (storage_engine = storage_engines[storage])
              self._storage = eval storage_engine
            else
              raise SalebotUploader::UnknownStorageError, "Unknown storage: #{storage}"
            end
          when nil
            storage
          else
            self._storage = storage
          end
          _storage
        end
        alias_method :storage=, :storage

        def cache_storage(storage = false)
          unless storage == false
            self._cache_storage = storage.is_a?(Symbol) ? eval(storage_engines[storage]) : storage
          end
          _cache_storage
        end
        alias_method :cache_storage=, :cache_storage

        def add_config(name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            @#{name} = nil

            def self.#{name}(value=nil)
              @#{name} = value unless value.nil?
              return @#{name} if self.object_id == #{self.object_id} || defined?(@#{name})
              name = superclass.#{name}
              return nil if name.nil? && !instance_variable_defined?(:@#{name})
              @#{name} = name && !name.is_a?(Module) && !name.is_a?(Symbol) && !name.is_a?(Numeric) && !name.is_a?(TrueClass) && !name.is_a?(FalseClass) ? name.dup : name
            end

            def self.#{name}=(value)
              @#{name} = value
            end

            def #{name}=(value)
              @#{name} = value
            end

            def #{name}
              value = @#{name} if instance_variable_defined?(:@#{name})
              value = self.class.#{name} unless instance_variable_defined?(:@#{name})
              if value.instance_of?(Proc)
                value.arity >= 1 ? value.call(self) : value.call
              else
                value
              end
            end
          RUBY
        end

        def add_deprecated_config(name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{name}(value=nil)
              ActiveSupport::Deprecation.warn "##{name} is deprecated and has no effect"
            end

            def self.#{name}=(value)
              ActiveSupport::Deprecation.warn "##{name} is deprecated and has no effect"
            end

            def #{name}=(value)
              ActiveSupport::Deprecation.warn "##{name} is deprecated and has no effect"
            end

            def #{name}
              ActiveSupport::Deprecation.warn "##{name} is deprecated and has no effect"
            end
          RUBY
        end

        def configure
          yield self
        end

        ##
        # sets configuration back to default
        #
        def reset_config
          configure do |config|
            config.permissions = 0o644
            config.directory_permissions = 0o755
            config.storage_engines = {
              :file => "SalebotUploader::Storage::File",
              :fog  => "SalebotUploader::Storage::Fog"
            }
            config.storage = :file
            config.cache_storage = nil
            config.fog_attributes = {}
            config.fog_credentials = {}
            config.fog_public = true
            config.fog_authenticated_url_expiration = 600
            config.fog_use_ssl_for_aws = true
            config.fog_aws_accelerate = false
            config.store_dir = 'uploads'
            config.cache_dir = 'uploads/tmp'
            config.delete_tmp_file_after_storage = true
            config.move_to_cache = false
            config.move_to_store = false
            config.remove_previously_stored_files_after_update = true
            config.downloader = SalebotUploader::Downloader::Base
            config.force_extension = false
            config.ignore_integrity_errors = true
            config.ignore_processing_errors = true
            config.ignore_download_errors = true
            config.validate_integrity = true
            config.validate_processing = true
            config.validate_download = true
            config.root = lambda { SalebotUploader.root }
            config.base_path = SalebotUploader.base_path
            config.enable_processing = true
            config.ensure_multipart_form = true
            config.download_retry_count = 0
            config.download_retry_wait_time = 5
            config.skip_ssrf_protection = false
          end
        end
      end

    end
  end
end
