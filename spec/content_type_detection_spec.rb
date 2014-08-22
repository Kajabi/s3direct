require 'spec_helper'

describe S3Direct::ContentTypeDetection do
  it "will have a content_type of audio/webm for sounds.webm audio/webm" do
    detection = S3Direct::ContentTypeDetection.new('sounds.webm', 'audio/webm')
    expect(detection.lookup).to eq('audio/webm')
  end

  it "will have a content_type of video/webm for sights.webm video/webm" do
    detection = S3Direct::ContentTypeDetection.new('signed.webm', 'video/webm')
    expect(detection.lookup).to eq('video/webm')
  end

  it "will have a content_type of audio/mpeg for sights.webm and a blank filetype" do
    detection = S3Direct::ContentTypeDetection.new('sing.mp3', '')
    expect(detection.lookup).to eq('audio/mpeg')
  end

  it "will have a content_type of video/mp4 for sights.mp4 and a 'video/mp4' filetype" do
    detection = S3Direct::ContentTypeDetection.new('sights.mp4', 'video/mp4')
    expect(detection.lookup).to eq('video/mp4')
  end

  it "will have a content_type of video/mp4 for sights.mp4 and a blank filetype" do
    detection = S3Direct::ContentTypeDetection.new('sights.mp4', '')
    expect(detection.lookup).to eq('video/mp4')
  end
end
