require "formula"

class Methpipe < Formula
  head "https://github.com/smithlabcode/methpipe.git"
  homepage "http://smithlabresearch.org/software/methpipe/"
  url "http://smithlabresearch.org/downloads/methpipe-3.3.1.tar.gz"
  sha1 "00dea4a51e7b8ed5e7020bba89db63a91d86a70f"

  depends_on "gsl" => :build

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
