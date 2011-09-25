$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'rmagick'
require 'travertine'

def load_test_image(filename)
  Magick::ImageList.new(File.join(File.dirname(__FILE__), 'data', 'images', filename)).first
end

RSpec::Matchers.define :be_same_image_as do |expected|
  match do |actual|
    if !((actual.columns == expected.columns) && (actual.rows == expected.rows))
      false
    else
      mean_error_per_pixel, normalized_mean_error, normalized_max_error = actual.difference(expected)

      # I'm not sure what a good normalized mean should be...
      # The difference between kensing.jpeg and kensing_defaced.jpeg is 0.0156
      normalized_mean_error - 0.005 < 0
    end
  end
end
