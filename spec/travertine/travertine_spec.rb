require 'spec_helper'

describe Travertine do
  let(:kensing) { load_test_image('kensing.jpeg') }
  let(:kensing_defaced) { load_test_image('kensing_defaced.jpeg') }
  let(:kensing_512) { load_test_image('kensing_512.jpeg') }
  let(:kensing_256) { load_test_image('kensing_256.jpeg') }
  let(:kensing_2048) { load_test_image('kensing_2048.jpeg') }
  let(:kensing_tile_2_0_2) { load_test_image('kensing_tile_2_0_2.jpeg') }

  describe "#cut_tiles" do
    it "should cut all tiles" do
      tile_sets = Travertine.cut_tiles(kensing, 2)
      tile_sets.size.should == 3

      tile_sets[0].size.should == 1
      tile_sets[1].size.should == 4
      tile_sets[2].size.should == 16

      tile_sets[2][2].should be_same_image_as(kensing_tile_2_0_2)
    end
  end

  describe "#cut_tile" do
    it "should cut the tile" do
      Travertine.cut_tile(kensing, 0, 2).should be_same_image_as(kensing_tile_2_0_2)
    end
  end

  describe "#tile_coordinates_for_zoom" do
    it "should calculate all the x,y pairs for a given zoom" do
      Travertine.tile_coordinates_for_zoom(0).should == [[0,0]]
      Travertine.tile_coordinates_for_zoom(1).should =~ [[0,0], [0,1], [1,0], [1,1]]

      Travertine.tile_coordinates_for_zoom(2).size.should == 16
      Travertine.tile_coordinates_for_zoom(2)[0..4].should =~ [[0,0], [0,1], [0,2], [0,3], [1,0]]

      Travertine.tile_coordinates_for_zoom(4).size.should == 256
      Travertine.tile_coordinates_for_zoom(4)[16..20].should =~ [[1,0], [1,1], [1,2], [1,3], [1,4]]
    end
  end

  describe "#tile_count_for_zoom" do
    it "should calculate the number of tiles for a given zoom level" do
      Travertine.tile_count_for_zoom(0).should == 1
      Travertine.tile_count_for_zoom(2).should == 16
      Travertine.tile_count_for_zoom(4).should == 256
    end
  end

  describe "#zoom_image_size" do
    it "should calculate the size in pixels that the source image must be resized to" do
      Travertine.zoom_image_size(0).should == Travertine::DEFAULT_TILE_SIZE
      Travertine.zoom_image_size(2).should == Travertine::DEFAULT_TILE_SIZE * 4
      Travertine.zoom_image_size(4).should == Travertine::DEFAULT_TILE_SIZE * 16

      Travertine.zoom_image_size(2, 100).should == 100 * 4
      Travertine.zoom_image_size(4, 1000).should == 1000 * 16
    end
  end

  describe "#resize_to_zoom_level" do
    it "should resize an image to the proper dimensions for the given zoom level" do
      Travertine.resize_to_zoom_level(kensing, 1, 256).should be_same_image_as(kensing_512)
      Travertine.resize_to_zoom_level(kensing, 3, 256).should be_same_image_as(kensing_2048)

      # Just a sanity check to make sure the image compare isn't crazy.
      Travertine.resize_to_zoom_level(kensing, 2, 256).should_not be_same_image_as(kensing_defaced)
    end

    it "should do an in-place resize, modifying the original image" do
      Travertine.resize_to_zoom_level(kensing, 3, 256).columns.should == 2048
      Travertine.resize_to_zoom_level(kensing, 3, 256).rows.should == 2048
    end
  end
end
