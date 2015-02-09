class Mlpack < Formula
  homepage "http://www.mlpack.org"
  url "https://github.com/mlpack/mlpack/archive/mlpack-1.0.12.tar.gz"
  sha1 "ad4909e4978edf03ff70d5f3d884efb24b5992a4"

  option :cxx11
  cxx11dep = (build.cxx11?) ? ['c++11'] : []

  depends_on "cmake" => :build
  depends_on "libxml2"
  depends_on "armadillo" => "with-hdf5"
  depends_on "boost" => cxx11dep
  depends_on "txt2man" => :optional

  option "with-debug", "Compile with debug options"
  option "with-profile", "Compile with profile options"
  option "without-check", "Disable build-time tests (not recommended)"

  def install
    ENV.cxx11 if build.cxx11?
    dylib = if OS.mac? then "dylib" else "so" end
    cmake_args = std_cmake_args
    cmake_args << "-DDEBUG=" + ((build.with? "debug") ? "ON" : "OFF")
    cmake_args << "-DPROFILE=" + ((build.with? "profile") ? "ON" : "OFF")
    cmake_args << "-DBOOST_ROOT=#{Formula['boost'].prefix}"
    cmake_args << "-DARMADILLO_INCLUDE_DIR=#{Formula['armadillo'].prefix}/include"
    cmake_args << "-DARMADILLO_LIBRARY=#{Formula['armadillo'].prefix}/lib/libarmadillo.#{dylib}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      #system "make", "test" if build.with? "check"
      system "make", "install"
      print "test"
    end
  end

  test do
    system "#{bin}/pca --help"
  end
end
