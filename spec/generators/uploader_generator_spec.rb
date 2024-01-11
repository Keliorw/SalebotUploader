# frozen_string_literal: true

require 'spec_helper'
require 'generator_spec'
require 'generators/uploader_generator'

describe UploaderGenerator, type: :generator do
  destination(File.expand_path('../tmp', __dir__))

  before { prepare_destination }

  it 'creates uploader file' do
    run_generator %w[Avatar]
    assert_file 'app/uploaders/avatar_uploader.rb', /class AvatarUploader < SalebotUploader::Uploader::Base/
  end

  it 'creates namespaced uploader file' do
    run_generator %w[MyModule::Avatar]
    assert_file 'app/uploaders/my_module/avatar_uploader.rb', /class MyModule::AvatarUploader < SalebotUploader::Uploader::Base/
  end
end
