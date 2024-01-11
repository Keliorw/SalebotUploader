module SalebotUploader
  module Uploader
    module Remove
      extend ActiveSupport::Concern

      include SalebotUploader::Uploader::Callbacks

      ##
      # Removes the file and reset it
      #
      def remove!
        with_callbacks(:remove) do
          @file.delete if @file
          @file = nil
          @cache_id = nil
        end
      end

    end # Remove
  end # Uploader
end # SalebotUploader
