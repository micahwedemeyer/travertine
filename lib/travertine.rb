class Travertine
  # This is the correct size for Google maps tiles
  DEFAULT_TILE_SIZE = 256

  # Cuts tiles from a source image at various zoom levels.
  #
  # Parameters:
  #
  # <tt>img</tt>: A +Magick::Image+ object for the source image. For proper tiling it should be exactly square.
  # <tt>max_zoom</tt>: The maximum level of zoom. max_zoom of 0 has 1 tile. Each successive level has 4 times as many tiles as the previous.
  # <tt>tile_size</tt>: The size of each tile in pixels.
  #
  # Returns:
  #
  # An +Array+ of +Arrays+, where each inner array contains the tiles for a given zoom level. The first +Array+ will have 1 tile, for zoom level 0. The second will have 4 for zoom level 1, and so on.
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

  # Cuts a tile from the source image.
  #
  # Parameters:
  #
  # <tt>img</tt>: A +Magick::Image+ object for the source image.
  # <tt>x</tt>: The x coordinate of the tile to cut. Coordinates are specified in terms of the tile grid, not pixels.
  # <tt>y</tt>: The y coordinate of the tile to cut. Coordinates are specified in terms of the tile grid, not pixels.
  # <tt>tile_size</tt>: The size of each tile in pixels.
  #
  # Returns:
  #
  # A +Magick::Image+ tile.
  def self.cut_tile(img, x, y, tile_size = DEFAULT_TILE_SIZE)
    tile = Magick::Image.new(tile_size, tile_size)

    img_x = x * tile_size
    img_y = y * tile_size

    tile.import_pixels(0, 0, tile_size, tile_size, "RGBA",img.export_pixels(img_x, img_y, tile_size, tile_size, "RGBA"))
  end

  # Calculates the tile grid for a given zoom level.
  #
  # Parameters:
  #
  # <tt>zoom_level</tt>: The level of zoom to compute the tile grid for.
  #
  # Returns:
  #
  # An +Array+ of 2-element +Arrays+ representing the tile x,y coordinates. For example, the tile grid at zoom 1 is [[0,0,], [0,1], [1,0], [1,1]]
  def self.tile_coordinates_for_zoom(zoom_level)
    [].tap do |coords|
      (0..((2 ** zoom_level) - 1)).each do |x|
        (0..((2 ** zoom_level) - 1)).each do |y|
          coords << [x,y]
        end
      end
    end
  end

  # Calculates the total tile count for a given zoom level.
  #
  # Parameters:
  #
  # <tt>zoom_level</tt>: The level of zoom to compute the tile grid for.
  #
  # Returns:
  #
  # An +Integer+ count of the number of tiles for a given zoom level.
  def self.tile_count_for_zoom(zoom_level)
    4 ** zoom_level
  end

  # Resizes the image to the correct size for cutting tiles at the given zoom level. It does an in-place resize which modifies the passed-in image.
  #
  # Note: If the image is not square, tiles will probably be incorrect.
  #
  # Parameters:
  #
  # <tt>img</tt>: The source image as +Magick::Image+.
  # <tt>zoom_level</tt>: The level of zoom to compute the tile grid for.
  # <tt>tile_size</tt>: The size of each tile in pixels.
  #
  # Returns:
  #
  # <tt>nil</tt> - The resize is done in-place, modifying the passed in image.
  def self.resize_to_zoom_level(img, zoom_level, tile_size = DEFAULT_TILE_SIZE)
    size = zoom_image_size(zoom_level, tile_size)
    img.resize!(size, size)
  end

  # Calculates the correct size in pixels for a source image at the given zoom level. This assumes the image
  # to resize will be square.
  #
  # For example, at zoom_level 2 and tile_size 256, the image size is 2048px on a side.
  #
  # Parameters:
  #
  # <tt>zoom_level</tt>: The level of zoom to compute the image size for.
  # <tt>tile_size</tt>: The size of each tile in pixels.
  #
  # Returns:
  #
  # The size in pixels of each side of the square image for a source image at the given zoom.
  def self.zoom_image_size(zoom_level, tile_size = DEFAULT_TILE_SIZE)
    tile_size * (2 ** zoom_level )
  end
end
