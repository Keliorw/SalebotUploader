module SalebotUploader
  module Uploader
    module Url
      extend ActiveSupport::Concern
      include SalebotUploader::Uploader::Configuration
      include SalebotUploader::Utilities::Uri

      ##
      # === Parameters
      #
      # [Hash] optional, the query params (only AWS)
      #
      # === Returns
      #
      # [String] the location where this file is accessible via a url
      #
      def url(options = {})
        if file.respond_to?(:url)
          tmp_url = file.method(:url).arity.zero? ? file.url : file.url(options)
          return tmp_url if tmp_url.present?
        end

        if file.respond_to?(:path)
          path = encode_path(file.path.sub(File.expand_path(root), ''))

          if (host = asset_host)
            if host.respond_to? :call
              "#{host.call(file)}#{path}"
            else
              "#{host}#{path}"
            end
          else
            (base_path || "") + path
          end
        end
      end

      def to_s
        url || ''
      end

    end # Url
  end # Uploader
end # SalebotUploader
