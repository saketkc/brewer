class Shogun < Formula
  homepage "http://www.shogun-toolbox.org"
  url "https://github.com/shogun-toolbox/shogun/archive/shogun_4.0.0.tar.gz"
  sha1 "dfcd62110613bee32c1583e4eb172875f0119317"

  head "https://github.com/shogun-toolbox/shogun.git"

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/science"
    sha1 "a4c6fcf6f847778a25483ef5e85a1ac71c510d09" => :yosemite
    sha1 "7ed6fd9c35fd9a42b4a7738a54d1adb6000f7812" => :mavericks
  end

  option "with-tests", "Build and run the tests"

  option "with-csharp-modular", "Build with c# modular interface"
  option "with-java-modular", "Build with java modular interface"
  option "with-lua-modular", "Build with lua modular interface"
  option "with-octave-modular", "Build with octave modular interface"
  option "with-python-modular", "Build with python modular interface"
  option "with-r-modular", "Build with R modular interface"

  option "with-lua-static", "Build with lua static interface"
  option "with-octave-static", "Build with octave static interface"
  option "with-python-static", "Build with python static interface"
  option "with-matlab-static", "Build with matlab static interface"
  option "with-r-static", "Build with R static interface"
  option "without-cmdline-static", "Build without command line static interface"

  option "with-brewed-numpy", "Build with Homebrew-packaged numpy"
  option "with-brewed-matplotlib", "Build with Homebrew-packaged matplotlib"

  depends_on "protobuf"
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "hdf5" => :recommended
  depends_on "json-c" => :recommended
  depends_on "readline" => :recommended
  depends_on "nlopt" => :recommended
  depends_on "eigen" => :recommended
  depends_on "glpk" => :recommended
  depends_on "lzo" => :recommended
  depends_on "snappy" => :recommended
  depends_on "xz" => :recommended  # provides lzma
  depends_on "swig" => [:recommended, :build] # needed for dynamic python bindings
  depends_on "homebrew/python/numpy" if build.with? "brewed-numpy"

  depends_on "homebrew/python/matplotlib" if build.with? "brewed-matplotlib"
  depends_on "r" if build.with?("r-static") || build.with?("r-modular")
  depends_on "lua" if build.with?("lua-static") || build.with?("lua-modular")
  depends_on "octave" if build.with?("octave-static") || build.with?("octave-modular")
  depends_on "python" if build.with?("brewed-numpy") || build.with?("brewed-matplotlib")
  depends_on "jblas" if build.with?("java-modular")
   resource "jinja2" do
       url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.1.tar.gz"
             sha1 "a9b24d887f2be772921b3ee30a0b9d435cffadda"
               end
  def install
    jinja2_dir = prefix/"jinja2"
    jinja2_site = jinja2_dir/"lib/python2.7/site-packages"
    jinja2_site.mkpath
    ENV.prepend_create_path "PYTHONPATH", jinja2_site
    resource("jinja2").stage {quiet_system "python2.7", "setup.py", "install", "--prefix=#{jinja2_dir}"}
    ENV.prepend_path "PATH", jinja2_dir/"bin"

    args = std_cmake_args
    args << "-DENABLE_TESTING=ON"
    args << "-DCmdLineStatic=ON" if build.with? "cmd-static"
    args << "-DCSharpModular=ON" if build.with? "csharp-modular"
    args << "-DJavaModular=ON" if build.with? "java-modular"
    args << "-DLuaModular=ON" if build.with? "lua-modular"
    args << "-DOctaveModular=ON" if build.with? "octave-modular"
    args << "-DPythonModular=ON" if build.with? "python-modular"
    args << "-DRModular=ON" if build.with? "r-modular"

    args << "-DLuaStatic=ON" if build.with? "lua-static"
    args << "-DOctaveStatic=ON" if build.with? "octave-static"
    args << "-DPythonStatic=ON" if build.with? "python-static"
    args << "-DRStatic=ON" if build.with? "r-static"
    args << "-DCmdLineStatic=ON" if build.with? "cmdline-static"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
      system "make", "unit-tests" if build.with? "tests"
    end
    share.install "examples"
  end

  test do
    system "#{share}/shogun/examples/libshogun/so_multiclass_BMRM"
  end
end
