require "formula"

class Samblaster < Formula
  homepage "https://github.com/GregoryFaust/samblaster"
  #doi "10.1093/bioinformatics/btu314"
  #tag "bioinformatics"
  
  url "https://github.com/GregoryFaust/samblaster/releases/download/v.0.1.20/samblaster-v.0.1.20.tar.gz"
  sha1 "202eef231c7d4e188a7ec1646702642ecf976037"
  head "https://github.com/GregoryFaust/samblaster"


  def install
    system "make"
    bin.install "samblaster"
  end

  test do
    system "samblaster --version"
  end
end
