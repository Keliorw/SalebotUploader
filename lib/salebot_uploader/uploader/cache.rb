require 'securerandom'

module SalebotUploader

  class FormNotMultipart < UploadError
    def message
      "You tried to assign a String or a Pathname to an uploader, for security reasons, this is not allowed.\n\n If this is a file upload, please check that your upload form is multipart encoded."
    end
  end

  class CacheCounter
    @@counter = 0

    def self.increment
      @@counter += 1
    end
  end

  ##
  # Generates a unique cache id for use in the caching system
  #
  # === Returns
  #
  # [String] a cache id in the format TIMEINT-PID-COUNTER-RND
  #
  def self.generate_cache_id
    [
      Time.now.utc.to_i,
      SecureRandom.random_number(1_000_000_000_000_000),
      '%04d' % (SalebotUploader::CacheCounter.increment % 10_000),
      '%04d' % SecureRandom.random_number(10_000)
    ].map(&:to_s).join('-')
  end

  module Uploader
    module Cache
      extend ActiveSupport::Concern

      include SalebotUploader::Uploader::Callbacks
      include SalebotUploader::Uploader::Configuration

      included do
        prepend Module.new {
          def initialize(*)
            super
            @staged = false
          end
        }
        attr_accessor :staged
      end

      module ClassMethods

        ##
        # Removes cached files which are older than one day. You could call this method
        # from a rake task to clean out old cached files.
        #
        # You can call this method directly on the module like this:
        #
        #   SalebotUploader.clean_cached_files!
        #
        # === Note
        #
        # This only works as long as you haven't done anything funky with your cache_dir.
        # It's recommended that you keep cache files in one place only.
        #
        def clean_cached_files!(seconds=60*60*24)
          (cache_storage || storage).new(new).clean_cache!(seconds)
        end
      end

      ##
      # Returns true if the uploader has been cached
      #
      # === Returns
      #
      # [Bool] whether the current file is cached
      #
      def cached?
        !!@cache_id
      end

      ##
      # Caches the remotely stored file
      #
      # This is useful when about to process images. Most processing solutions
      # require the file to be stored on the local filesystem.
      #
      def cache_stored_file!
        cache!
      end

      def sanitized_file
        ActiveSupport::Deprecation.warn('#sanitized_file is deprecated, use #file instead.')
        file
      end

      ##
      # Returns a String which uniquely identifies the currently cached file for later retrieval
      #
      # === Returns
      #
      # [String] a cache name, in the format TIMEINT-PID-COUNTER-RND/filename.txt
      #
      def cache_name
        File.join(cache_id, original_filename) if cache_id && original_filename
      end

      ##
      # Caches the given file. Calls process! to trigger any process callbacks.
      #
      # By default, cache!() uses copy_to(), which operates by copying the file
      # to the cache, then deleting the original file.  If move_to_cache() is
      # overridden to return true, then cache!() uses move_to(), which simply
      # moves the file to the cache.  Useful for large files.
      #
      # === Parameters
      #
      # [new_file (File, IOString, Tempfile)] any kind of file object
      #
      # === Raises
      #
      # [SalebotUploader::FormNotMultipart] if the assigned parameter is a string
      #
      def cache!(new_file = file)
        new_file = SalebotUploader::SanitizedFile.new(new_file)
        return if new_file.empty?

        raise SalebotUploader::FormNotMultipart if new_file.is_path? && ensure_multipart_form

        self.cache_id = SalebotUploader.generate_cache_id unless cache_id

        @identifier = nil
        @staged = true
        @filename = new_file.filename
        self.original_filename = new_file.filename

        begin
          # first, create a workfile on which we perform processings
          if move_to_cache
            @file = new_file.move_to(File.expand_path(workfile_path, root), permissions, directory_permissions)
          else
            @file = new_file.copy_to(File.expand_path(workfile_path, root), permissions, directory_permissions)
          end

          with_callbacks(:cache, @file) do
            @file = cache_storage.cache!(@file)
          end
        ensure
          FileUtils.rm_rf(workfile_path(''))
        end
      end

      ##
      # Retrieves the file with the given cache_name from the cache.
      #
      # === Parameters
      #
      # [cache_name (String)] uniquely identifies a cache file
      #
      # === Raises
      #
      # [SalebotUploader::InvalidParameter] if the cache_name is incorrectly formatted.
      #
      def retrieve_from_cache!(cache_name)
        with_callbacks(:retrieve_from_cache, cache_name) do
          self.cache_id, self.original_filename = cache_name.to_s.split('/', 2)
          @staged = true
          @filename = original_filename
          @file = cache_storage.retrieve_from_cache!(full_original_filename)
        end
      end

      ##
      # Calculates the path where the cache file should be stored.
      #
      # === Parameters
      #
      # [for_file (String)] name of the file <optional>
      #
      # === Returns
      #
      # [String] the cache path
      #
      def cache_path(for_file=full_original_filename)
        File.join(*[cache_dir, @cache_id, for_file].compact)
      end

    protected

      attr_reader :cache_id

    private

      def workfile_path(for_file=original_filename)
        File.join(SalebotUploader.tmp_path, @cache_id, version_name.to_s, for_file)
      end

      attr_reader :original_filename

      def cache_id=(cache_id)
        # Earlier version used 3 part cache_id. Thus we should allow for
        # the cache_id to have both 3 part and 4 part formats.
        raise SalebotUploader::InvalidParameter, "invalid cache id" unless cache_id =~ /\A(-)?[\d]+\-[\d]+(\-[\d]{4})?\-[\d]{4}\z/
        @cache_id = cache_id
      end

      def original_filename=(filename)
        raise SalebotUploader::InvalidParameter, "invalid filename" if filename =~ SalebotUploader::SanitizedFile.sanitize_regexp
        @original_filename = filename
      end

      def cache_storage
        @cache_storage ||= (self.class.cache_storage || self.class.storage).new(self)
      end

      # We can override the full_original_filename method in other modules
      def full_original_filename
        forcing_extension(original_filename)
      end
    end # Cache
  end # Uploader
end # SalebotUploader