require "formula"

class Armadillo < Formula
  homepage "http://arma.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/arma/armadillo-4.600.2.tar.gz"
  sha1 "1b008706f52b154faeec3f6fcc8c98076ae9e5b9"

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/science"
    sha1 "de8127e4a288f77632b80c17373044e94a0656d2" => :yosemite
    sha1 "ba1520f259937d34c5c1bd878fccc7e9518bc3ef" => :mavericks
    sha1 "64ed43d130bfab2333c39ceb64eb2adea0506e2a" => :mountain_lion
  end

  option "with-hdf5", "Enable the ability to save and load matrices stored in the HDF5 format"

  depends_on "cmake" => :build
  depends_on "arpack"
  depends_on "openblas" => :build

  depends_on "hdf5" if build.with? "hdf5"

  option :cxx11

  def install
    ENV.cxx11 if build.cxx11?
    if build.with?("hdf5")
      inreplace "include/armadillo_bits/config.hpp" do |s|
        s.gsub! /\/\/ #define ARMA_USE_HDF5.*/, "#define ARMA_USE_HDF5"
      end
    end

    system "cmake", ".", *std_cmake_args
    system "make", "install"

    # Copy examples/ directory to prefix
    prefix.install "examples"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <armadillo>
      using namespace std;
      using namespace arma;

      int main(int argc, char** argv)
        {
        cout << arma_version::as_string() << endl;
        }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{lib}", "-larmadillo", "-o", "test"
    assert `./test`.include?(version)
  end
end
