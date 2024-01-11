# frozen_string_literal: true

require 'spec_helper'

describe SalebotUploader::Uploader do
  let(:uploader_class) { Class.new(SalebotUploader::Uploader::Base) }
  let(:uploader) { uploader_class.new }

  after { FileUtils.rm_rf(public_path) }

  describe '#root' do
    describe "default behavior" do
      before { SalebotUploader.root = public_path }

      it "defaults to the current value of SalebotUploader.root" do
        expect(uploader.root).to eq(public_path)
      end
    end
  end
end
