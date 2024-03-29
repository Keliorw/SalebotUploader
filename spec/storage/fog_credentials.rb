# frozen_string_literal: true

unless defined?(FOG_CREDENTIALS)

  credentials = []

  if Fog.mocking?
    # Local and Rackspace don't have fog double support yet
    mappings = {
      'AWS' => %i[aws_access_key_id aws_secret_access_key],
      'Google' => %i[google_storage_access_key_id google_storage_secret_access_key],
      # 'Local'     => [:local_root],
      # 'Rackspace' => [:rackspace_api_key, :rackspace_username]
    }

    mappings.each do |provider, keys|
      data = { provider: provider }
      keys.each do |key|
        data[key] = key.to_s
      end
      credentials << data
    end

    FOG_CREDENTIALS = credentials
    SALEBOT_UPLOADER_DIRECTORY = 'salebot_uploader'
  else
    Fog.credential = :salebot_uploader

    mappings = {
      'AWS' => %i[aws_access_key_id aws_secret_access_key],
      'Google' => %i[google_storage_access_key_id google_storage_secret_access_key google_project google_json_key_string],
      # 'Local'     => [:local_root],
      # 'Rackspace' => [:rackspace_api_key, :rackspace_username]
    }

    mappings.each do |provider, keys|
      next if (creds = Fog.credentials.select { |key, value| [*keys].include?(key) }).empty?

      data = { provider: provider }
      keys.each do |key|
        data[key] = creds[key] unless creds[key].blank?
      end
      credentials << data
    end

    FOG_CREDENTIALS = credentials
    SALEBOT_UPLOADER_DIRECTORY = "salebot_uploader-#{ENV['USER']}-dev" unless defined?(SALEBOT_UPLOADER_DIRECTORY)
  end

end
