require "formula"

class UniversalPython < Requirement
  satisfy(:build_env => false) { archs_for_command("python").universal? }

  def message; <<-EOS.undent
    A universal build was requested, but Python is not a universal build

    Boost compiles against the Python it finds in the path; if this Python
    is not a universal build then linking will likely fail.
    EOS
  end
end

class Boost149 < Formula
  homepage 'http://www.boost.org'
  url 'https://downloads.sourceforge.net/project/boost/boost/1.49.0/boost_1_49_0.tar.bz2'
  sha1 '26a52840e9d12f829e3008589abf0a925ce88524'

  keg_only "Boost 1.49 is provided for software that doesn't compile against newer versions."

  env :userpaths

  option :universal
  option 'with-icu', 'Build regexp engine with icu support'

  depends_on :python => :recommended
  depends_on UniversalPython if build.universal? and build.with? "python"
  depends_on "icu4c" if build.with? 'icu'
  depends_on :mpi => [:cc, :cxx, :optional]

  fails_with :llvm do
    build 2335
    cause "Dropped arguments to functions when linking with boost"
  end

  # Security fix for Boost.Locale. For details: http://www.boost.org/users/news/boost_locale_security_notice.html
  patch :p0 do
    url "http://cppcms.com/files/locale/boost_locale_utf.patch"
    sha1 "f9f1e5fc2e4d65fa592c72df6e807ba6b02fad21"
  end

  patch :p1 do
    url "https://bugs.debian.org/cgi-bin/bugreport.cgi?msg=22;filename=gcc4.8_trac-7242.patch;att=2;bug=701377"
    sha1 "4e7526e895c259e1f03568a45a71c3ffb7091e69"
  end

  patch :p1 do
    url "https://bugs.debian.org/cgi-bin/bugreport.cgi?msg=22;filename=c11_trac-6940.patch;att=1;bug=701377"
    sha1 "134380b3fd077dc36f298328c8913a96a5044d8e"
  end

  def install
    # Adjust the name the libs are installed under to include the path to the
    # full keg library location.
    if OS.mac?
      inreplace 'tools/build/v2/tools/darwin.jam',
                '-install_name "',
                "-install_name \"#{lib}/"
    end

    # Force boost to compile using the appropriate GCC version
    open("user-config.jam", "a") do |file|
      if OS.mac?
        file.write "using darwin : : #{ENV.cxx} ;\n"
      else
        file.write "using gcc : : #{ENV.cxx} ;\n"
      end
      file.write "using mpi ;\n" if build.with? 'mpi'
    end

    # we specify libdir too because the script is apparently broken
    bargs = ["--prefix=#{prefix}", "--libdir=#{lib}", "--without-libraries=signals"]

    if build.with? 'icu'
      icu4c_prefix = Formula["icu4c"].opt_prefix
      bargs << "--with-icu=#{icu4c_prefix}"
    else
      bargs << '--without-icu'
    end

    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-d2",
            "-j#{ENV.make_jobs}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "threading=multi",
            "install"]

    args << "boost.locale.posix=off" << "boost.locale.icu=off" if OS.linux?
    args << "address-model=32_64" << "architecture=x86" << "pch=off" if build.universal?
    args << "--without-python" if build.without? 'python'

    system "./bootstrap.sh", *bargs
    system "./bjam", *args
  end
end
