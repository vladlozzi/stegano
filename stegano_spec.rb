require 'rspec'
require_relative 'stegano.rb'

describe "Steganography" do

  before(:all) do
    @string_to_encrypt = "Glory to Ukraine! Glory to Heroes! Glory Forever!"
    @source = "samsung860pro512Gb.bmp"
    @target = "ssd_samsung860pro512Gb.bmp"
  end

  it "should be encrypted and decrypted" do
    stegano1 = Steganography.new(@source, @string_to_encrypt, @target)
    stegano1.encrypt
    source = @target
    stegano2 = Steganography.new(source)
    decrypted_string = stegano2.decrypt
    expect(decrypted_string).to eq @string_to_encrypt
  end

end
