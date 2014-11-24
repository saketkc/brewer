require "formula"

class Samblaster < Formula
  homepage "https://github.com/GregoryFaust/samblaster"
  #tag "bioinformatics"
  
  url "https://github.com/GregoryFaust/samblaster/releases/download/v.0.1.20/samblaster-v.0.1.20.tar.gz"
  head "https://github.com/GregoryFaust/samblaster"

  #depends_on "gcc" => :build

  def install
    system "make"
    bin.install "samblaster"
  end

  test do
    system "#{bin}/samblaster"
  end
end
