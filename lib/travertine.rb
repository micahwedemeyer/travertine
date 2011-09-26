class Travertine

  # This is the correct size for Google maps tiles
  DEFAULT_TILE_SIZE = 256

  def self.cut_tiles(img, max_zoom, tile_size = DEFAULT_TILE_SIZE)
    tile_sets = []
    (0..max_zoom).collect.reverse.each do |zoom|
      tiles = []
      resize_to_zoom_level(img, zoom, tile_size)
      tile_coordinates_for_zoom(zoom).each do |x,y|
        tiles << cut_tile(img, x, y, tile_size)
      end

      tile_sets << tiles
    end

    tile_sets.reverse
  end

  def self.cut_tile(img, x, y, tile_size = DEFAULT_TILE_SIZE)
    tile = Magick::Image.new(tile_size, tile_size)

    img_x = x * tile_size
    img_y = y * tile_size

    tile.import_pixels(0, 0, tile_size, tile_size, "RGBA",img.export_pixels(img_x, img_y, tile_size, tile_size, "RGBA"))
  end

  def self.tile_coordinates_for_zoom(zoom_level)
    [].tap do |coords|
      (0..((2 ** zoom_level) - 1)).each do |x|
        (0..((2 ** zoom_level) - 1)).each do |y|
          coords << [x,y]
        end
      end
    end
  end

  def self.resize_to_zoom_level(img, zoom_level, tile_size = DEFAULT_TILE_SIZE)
    size = zoom_image_size(zoom_level, tile_size)
    img.resize!(size, size)
  end

  def self.zoom_image_size(zoom_level, tile_size = DEFAULT_TILE_SIZE)
    tile_size * (2 ** zoom_level )
  end
end
