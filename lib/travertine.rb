class Travertine

  DEFAULT_TILE_SIZE = 256

  def self.resize_to_zoom_level(img, zoom_level, tile_size = DEFAULT_TILE_SIZE)
    size = zoom_image_size(zoom_level, tile_size)
    img.resize!(size, size)
  end

  def self.zoom_image_size(zoom_level, tile_size = DEFAULT_TILE_SIZE)
    tile_size * (2 ** (zoom_level - 1))
  end
end
