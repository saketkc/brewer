require "formula"

class Methpipe < Formula
  head "https://github.com/smithlabcode/methpipe.git"
  homepage "http://smithlabresearch.org/software/methpipe/"
  #tag "bioinformatics"
  #doi "10.1371/journal.pone.0081148"
  
  url "http://smithlabresearch.org/downloads/methpipe-3.3.1.tar.gz"
  sha1 "00dea4a51e7b8ed5e7020bba89db63a91d86a70f"

  depends_on "gsl"

  def install
    ENV.deparallelize
    system "make", "all"
    system "make", "install"
    prefix.install 'bin'
  end

  test do
    system "symmetric-cpgs -about"
  end
end
