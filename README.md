# Steganography class

This class is designed to hide (encrypt) and render (decrypt) a string in a graphics file using steganography.

This class supports:
* ASCII 8-bit string to encrypt only
* 24-bit bitmap images only

## Using example

    string_to_encrypt = "Glory to Ukraine! Glory to Heroes! Glory Forever!"
    source = "samsung860pro512Gb.bmp"
    target = "ssd_samsung860pro512Gb.bmp"

    stegano1 = Steganography.new(source, string_to_encrypt, target)
    stegano1.encrypt
    
    source = target
    stegano2 = Steganography.new(source)
    decrypted_string = stegano2.decrypt

    puts decrypted_string == string_to_encrypt # Should put true.
    puts decrypted_string # Should put the string_to_encrypt value.
