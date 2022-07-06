class Stegano
  #
  # This class supports:
  #   - ASCII 8-bit string_to_encrypt only
  #   - 24-bit bitmap images only
  #
  def initialize(source, string_to_crypt = "",  target = "")
    if File.file?(source)
      @source_bmp = File.binread(source)
      return nil if @source_bmp[0..1] != 'BM'
      @source_length = @source_bmp[2..5].unpack('l').first
      @pixels_offset = @source_bmp[10..13].unpack('l').first
      @pixels_width = @source_bmp[18..21].unpack('L').first
      @pixels_height = @source_bmp[22..25].unpack('L').first
      @bpp = @source_bmp[28..29].unpack('s').first
      return nil if @bpp != 24
      @string_to_crypt = string_to_crypt
      @target = target
    else
      puts "Oops, source image file \"#{source}\" not found."
    end
  end

  def encrypt
    return nil if @string_to_crypt.empty? || @target.empty?
    create_array_to_crypt_bin
    read_pixels_area
    replace_bytes_in_blue
    replace_last_bits_in_red
    replace_layers_in_pixels_area
    create_and_write_target_bitmap
  end

  private

  def create_array_to_crypt_bin
    string_to_crypt_bin = []
    @string_to_crypt.each_byte{ |byte|
      string_to_crypt_bin << sprintf("%8b", byte).sub(' ','0').chars.map(&:to_i)
    }
    @array_to_crypt_bin = string_to_crypt_bin.flatten
  end

  def read_pixels_area
      pixels_area = @source_bmp[@pixels_offset..-1]
      @pixels_area_bin = pixels_area.chars.map{ |c| c.unpack('C').first.to_s(2) }
  end

  def replace_bytes_in_blue
      # Replace first four bytes with string length in blue layer.
      bytes_in_string = @string_to_crypt.length.to_s(2)
      total_bytes_in_string = ("0" * (32 - bytes_in_string.length) + bytes_in_string).scan(/\d{8}/)
      @blue_layer = @pixels_area_bin.select.each_with_index{ |_, i| i % 3 == 2 }[0..3]
      i = 0; total_bytes_in_string.map{ |byte| @blue_layer[i] = byte.to_s; i += 1 }
  end

  def replace_last_bits_in_red
      @red_layer = @pixels_area_bin.select.each_with_index{ |_, i| i % 3 == 0 }
      i = 0; @array_to_crypt_bin.map{ |bit| @red_layer[i][7] = bit.to_s; i += 1 }
  end

  def replace_layers_in_pixels_area
     @blue_layer.map.with_index{ |byte, i| @pixels_area_bin[3 * i + 2] = byte }
     @red_layer.map.with_index{ |byte, i| @pixels_area_bin[3 * i] = byte }
     @pixels_area = @pixels_area_bin.map{ |s| [s.to_i(2)].pack('C') }.join
  end

  def create_and_write_target_bitmap
      # First append changed pixels area to header.
      target_bmp = @source_bmp[0..@pixels_offset - 1] + @pixels_area
      puts "Target image file will have #{target_bmp.length} byte(s)."
      if File.binwrite(@target, target_bmp) == target_bmp.length
        puts "Yes, target image file \"#{@target}\" was written successfully."
      end
  end

end

def stegano_decrypt(image)
  #
  # This method supports:
  #   - ASCII 8-bit string_to_encrypt only
  #   - 24-bit bitmap images only
  #
  if File.file?(image)
    puts "Yes, encrypted image file \"#{image}\" exists."
    # Read info from bitmap file.
    image_bmp = File.binread(image)
    return nil if image_bmp[0..1] != 'BM'
    image_length = image_bmp[2..5].unpack('l').first
    pixels_offset = image_bmp[10..13].unpack('l').first
    pixels_width = image_bmp[18..21].unpack('L').first
    pixels_height = image_bmp[22..25].unpack('L').first
    bpp = image_bmp[28..29].unpack('s').first
    return nil if bpp != 24

    puts "Image file length is #{image_length} byte(s)."
    puts "Pixel datas offset is #{pixels_offset}."
    puts "Image size is #{pixels_width}x#{pixels_height} (#{bpp} bpp)."

    # Read pixels area.
    pixels_area = image_bmp[pixels_offset..-1]
    pixels_area_bin = pixels_area.chars.map{ |c| c.unpack('C').first.to_s(2) }

    # Select blue layer and read length of encrypted string from its initial four bytes.
    string_length = pixels_area_bin.select.each_with_index{ |_, i| i % 3 == 2 }[0..3].join.to_i(2)

    # Select red layer and read last bit in each byte.
    red_layer = pixels_area_bin.select.each_with_index{ |_, i| i % 3 == 0 }[0..(string_length * 8) - 1]
    decrypted_string = red_layer.map{ |byte| byte[7] }.join.scan(/\d{8}/).map{ |byte| byte.to_i(2).chr }.join

    puts "Yes, encrypted string was extracted from image file successfully."
    decrypted_string
  else
    puts "Oops, encrypted bmp file \"#{image}\" not found."
  end
end

# Stegano class using example.
string_to_encrypt = "Glory to Ukraine! Glory to Heroes! Glory Forever!"
source = "samsung860pro512Gb.bmp"
target = "ssd_samsung860pro512Gb.bmp"

stegano = Stegano.new(source, string_to_encrypt, target)
stegano.encrypt

p stegano_decrypt(target) == string_to_encrypt # Should be true.