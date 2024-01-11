module SalebotUploader
  module Uploader
    module Download
      extend ActiveSupport::Concern

      include SalebotUploader::Uploader::Callbacks
      include SalebotUploader::Uploader::Configuration
      include SalebotUploader::Uploader::Cache

      ##
      # Caches the file by downloading it from the given URL, using downloader.
      #
      # === Parameters
      #
      # [url (String)] The URL where the remote file is stored
      # [remote_headers (Hash)] Request headers
      #
      def download!(uri, remote_headers = {})
        file = downloader.new(self).download(uri, remote_headers)
        cache!(file)
      end
    end # Download
  end # Uploader
end # SalebotUploader
