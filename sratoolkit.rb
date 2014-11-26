require "formula"

class Sratoolkit < Formula
  homepage "https://github.com/ncbi/sra-tools/archive/2.4.2-3.tar.gz"
  version "2.4.2-3"
  url "https://github.com/ncbi/sra-tools/archive/#{version}.tar.gz"
  sha1 "5c7dcf97bae1bb4a1eb48cca982ebf5fca7c3584"
  head "https://github.com/ncbi/sra-tools.git"

  resource "ngs-sdk" do
    url "https://github.com/ncbi/ngs/archive/1.0.0.tar.gz"
    sha1 "3356d4c1da43772740436b116ab0fe53eb6749d8"
  end

  resource "ncbi-vdb" do
    url "https://github.com/ncbi/ncbi-vdb/archive/2.4.2-4.tar.gz"
    sha1 "52be99462320f22e9219819177f29446cd8e52d3"
  end

  depends_on "autoconf" => :build
  depends_on "libxml2" => :recommended
  #depends_on "libmagic" => :recommended
  depends_on "hdf5" => :recommended
  
  def install
    ENV.deparallelize
    resource("ngs-sdk").stage do
      cd "ngs-sdk" do
        system "./configure", "--prefix=#{prefix}", "--build=#{prefix}"
        system "make"
        system "make", "install"
      end
    end

    resource("ncbi-vdb").stage do
      system "./configure", "--with-ngs-sdk-prefix=#{prefix}", "--prefix=#{prefix}", "--build=#{prefix}"
      system "make"
      system "make", "install"
      (include/"ncbi-vdb").install Dir["*"]
    end

    system "./configure", "--prefix=#{prefix}", "--with-ngs-sdk-prefix=#{prefix}", "--with-ncbi-vdb-sources=#{include}/ncbi-vdb", "--with-ncbi-vdb-build=#{prefix}", "--prefix=#{prefix}", "--build=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system 'fastq-dump --version'
  end
end
