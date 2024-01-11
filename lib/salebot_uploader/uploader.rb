require 'salebot_uploader/uploader/configuration'
require 'salebot_uploader/uploader/callbacks'
require 'salebot_uploader/uploader/proxy'
require 'salebot_uploader/uploader/url'
require 'salebot_uploader/uploader/mountable'
require 'salebot_uploader/uploader/cache'
require 'salebot_uploader/uploader/store'
require 'salebot_uploader/uploader/download'
require 'salebot_uploader/uploader/remove'
require 'salebot_uploader/uploader/extension_allowlist'
require 'salebot_uploader/uploader/extension_denylist'
require 'salebot_uploader/uploader/content_type_allowlist'
require 'salebot_uploader/uploader/content_type_denylist'
require 'salebot_uploader/uploader/file_size'
require 'salebot_uploader/uploader/dimension'
require 'salebot_uploader/uploader/processing'
require 'salebot_uploader/uploader/versions'
require 'salebot_uploader/uploader/default_url'

require 'salebot_uploader/uploader/serialization'

module SalebotUploader

  ##
  # See SalebotUploader::Uploader::Base
  #
  module Uploader
    class Base
      attr_reader :file

      include SalebotUploader::Uploader::Configuration
      include SalebotUploader::Uploader::Callbacks
      include SalebotUploader::Uploader::Proxy
      include SalebotUploader::Uploader::Url
      include SalebotUploader::Uploader::Mountable
      include SalebotUploader::Uploader::Cache
      include SalebotUploader::Uploader::Store
      include SalebotUploader::Uploader::Download
      include SalebotUploader::Uploader::Remove
      include SalebotUploader::Uploader::ExtensionAllowlist
      include SalebotUploader::Uploader::ExtensionDenylist
      include SalebotUploader::Uploader::ContentTypeAllowlist
      include SalebotUploader::Uploader::ContentTypeDenylist
      include SalebotUploader::Uploader::FileSize
      include SalebotUploader::Uploader::Dimension
      include SalebotUploader::Uploader::Processing
      include SalebotUploader::Uploader::Versions
      include SalebotUploader::Uploader::DefaultUrl
      include SalebotUploader::Uploader::Serialization
    end

  end 
end
