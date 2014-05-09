require 'formula'

class NgxOpenresty < Formula
  homepage 'http://openresty.org/'

  url 'http://openresty.org/download/ngx_openresty-1.5.12.1.tar.gz'
  sha1 '3d6a0b0dc10a3618ee5b5e478cd477e4cd66989d'

  depends_on 'pcre'
  depends_on 'postgresql' => :optional

  # openresty options
  option 'without-luajit', "Compile *without* support for the Lua Just-In-Time Compiler"
  option 'with-postgresql', "Compile with support for direct communication with PostgreSQL database servers"
  option 'with-iconv', "Compile with support for converting character encodings"

  option 'with-debug', "Compile with support for debug logging but without proper gdb debugging symbols"

  # nginx options
  option 'with-webdav', "Compile with ngx_http_dav_module"
  option 'with-gunzip', "Compile with ngx_http_gunzip_module"

  # luajit options
  option 'with-luajit-checkhook', "Activate debug.sethook(...) compatibility in LuaJIT"

  skip_clean 'logs'

  def install
    args = ["--prefix=#{prefix}",
      "--with-http_ssl_module",
      "--with-pcre",
      "--with-pcre-jit",
      "--sbin-path=#{bin}/openresty",
      "--conf-path=#{etc}/openresty/nginx.conf",
      "--pid-path=#{var}/run/openresty.pid",
      "--lock-path=#{var}/openresty/nginx.lock"
    ]

    args << "--with-http_dav_module" if build.with? 'webdav'
    args << "--with-http_gunzip_module" if build.with? 'gunzip'

    # Debugging mode, unfortunately without debugging symbols
    if build.with? 'debug'
      args << '--with-debug'
      args << '--with-dtrace-probes'
      args << '--with-no-pool-patch'

      opoo "Openresty will be built --with-debug option, but without debugging symbols. For debugging symbols you have to compile it by hand."
    end

    # OpenResty options
    args << "--with-lua51" if build.without? 'luajit'

    args << "--with-http_postgres_module" if build.with? 'postgres'
    args << "--with-http_iconv_module" if build.with? 'iconv'

    args << "--with-luajit-xcflags=-DLUAJIT_ENABLE_CHECKHOOK" if build.with? 'luajit-checkhook'

    system "./configure", *args

    system "make"
    system "make install"
  end
end
