module SalebotUploader
  module MiniMagick
    extend ActiveSupport::Concern

    included do
      require "image_processing/mini_magick"
    end

    module ClassMethods
      def convert(format)
        process :convert => format
      end

      def resize_to_limit(width, height)
        process :resize_to_limit => [width, height]
      end

      def resize_to_fit(width, height)
        process :resize_to_fit => [width, height]
      end

      def resize_to_fill(width, height, gravity='Center')
        process :resize_to_fill => [width, height, gravity]
      end

      def resize_and_pad(width, height, background=:transparent, gravity='Center')
        process :resize_and_pad => [width, height, background, gravity]
      end
    end
    def convert(format, page=nil, &block)
      minimagick!(block) do |builder|
        builder = builder.convert(format)
        builder = builder.loader(page: page) if page
        builder
      end
    end

    def resize_to_limit(width, height, combine_options: {}, &block)
      width, height = resolve_dimensions(width, height)

      minimagick!(block) do |builder|
        builder.resize_to_limit(width, height)
          .apply(combine_options)
      end
    end

    def resize_to_fit(width, height, combine_options: {}, &block)
      width, height = resolve_dimensions(width, height)

      minimagick!(block) do |builder|
        builder.resize_to_fit(width, height)
          .apply(combine_options)
      end
    end

    def resize_to_fill(width, height, gravity = 'Center', combine_options: {}, &block)
      width, height = resolve_dimensions(width, height)

      minimagick!(block) do |builder|
        builder.resize_to_fill(width, height, gravity: gravity)
          .apply(combine_options)
      end
    end

    def resize_and_pad(width, height, background=:transparent, gravity='Center', combine_options: {}, &block)
      width, height = resolve_dimensions(width, height)

      minimagick!(block) do |builder|
        builder.resize_and_pad(width, height, background: background, gravity: gravity)
          .apply(combine_options)
      end
    end

    ##
    # Returns the width of the image in pixels.
    #
    # === Returns
    #
    # [Integer] the image's width in pixels
    #
    def width
      mini_magick_image[:width]
    end

    ##
    # Returns the height of the image in pixels.
    #
    # === Returns
    #
    # [Integer] the image's height in pixels
    #
    def height
      mini_magick_image[:height]
    end

    ##
    # Manipulate the image with MiniMagick. This method will load up an image
    # and then pass each of its frames to the supplied block. It will then
    # save the image to disk.
    #
    # NOTE: This method exists mostly for backwards compatibility, you should
    # probably use #minimagick!.
    #
    # === Gotcha
    #
    # This method assumes that the object responds to +current_path+.
    # Any class that this module is mixed into must have a +current_path+ method.
    # SalebotUploader::Uploader does, so you won't need to worry about this in
    # most cases.
    #
    # === Yields
    #
    # [MiniMagick::Image] manipulations to perform
    #
    # === Raises
    #
    # [SalebotUploader::ProcessingError] if manipulation failed.
    #
    def manipulate!
      cache_stored_file! if !cached?
      image = ::MiniMagick::Image.open(current_path)

      image = yield(image)
      FileUtils.mv image.path, current_path

      image.run_command("identify", current_path)
    rescue ::MiniMagick::Error, ::MiniMagick::Invalid => e
      raise e if e.message =~ /(You must have .+ installed|is not installed|executable not found)/
      message = I18n.translate(:"errors.messages.processing_error")
      raise SalebotUploader::ProcessingError, message
    ensure
      image.destroy! if image
    end

    # Process the image with MiniMagick, using the ImageProcessing gem. This
    # method will build a "convert" ImageMagick command and execute it on the
    # current image.
    #
    # === Gotcha
    #
    # This method assumes that the object responds to +current_path+.
    # Any class that this module is mixed into must have a +current_path+ method.
    # SalebotUploader::Uploader does, so you won't need to worry about this in
    # most cases.
    #
    # === Yields
    #
    # [ImageProcessing::Builder] use it to define processing to be performed
    #
    # === Raises
    #
    # [SalebotUploader::ProcessingError] if processing failed.
    def minimagick!(block = nil)
      builder = ImageProcessing::MiniMagick.source(current_path)
      builder = yield(builder)

      result = builder.call
      result.close

      # backwards compatibility (we want to eventually move away from MiniMagick::Image)
      if block
        image  = ::MiniMagick::Image.new(result.path, result)
        image  = block.call(image)
        result = image.instance_variable_get(:@tempfile)
      end

      FileUtils.mv result.path, current_path

      if File.extname(result.path) != File.extname(current_path)
        move_to = current_path.chomp(File.extname(current_path)) + File.extname(result.path)
        file.content_type = Marcel::Magic.by_path(move_to).try(:type)
        file.move_to(move_to, permissions, directory_permissions)
      end
    rescue ::MiniMagick::Error, ::MiniMagick::Invalid => e
      raise e if e.message =~ /(You must have .+ installed|is not installed|executable not found)/
      message = I18n.translate(:"errors.messages.processing_error")
      raise SalebotUploader::ProcessingError, message
    end

  private

    def resolve_dimensions(*dimensions)
      dimensions.map do |value|
        next value unless value.instance_of?(Proc)
        value.arity >= 1 ? value.call(self) : value.call
      end
    end

    def mini_magick_image
      ::MiniMagick::Image.read(read)
    end

  end # MiniMagick
end # SalebotUploader
