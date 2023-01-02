FROM registry.gitlab.steamos.cloud/steamrt/soldier/sdk:0.20220824.0

RUN apt install -y wget xz-utils bzip2 make autoconf gcc-multilib g++-multilib libnss3-dev
RUN wget https://ftp.wrz.de/pub/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.xz
RUN tar xf gcc-10.2.0.tar.xz
RUN WORKDIR /root/gcc-10.2.0
RUN wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
RUN tar xf gmp-6.2.0.tar.xz
RUN mv gmp-6.2.0 gmp
RUN wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.gz
RUN tar xf mpfr-4.1.0.tar.gz
RUN mv mpfr-4.1.0 mpfr
RUN wget ftp://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz
RUN tar xf mpc-1.2.1.tar.gz
RUN mv mpc-1.2.1 mpc
RUN wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2
RUN tar xf isl-0.18.tar.bz2
RUN mv isl-0.18 isl

RUN ./configure --prefix=/opt/gcc-10 --enable-languages=c,c++
RUN make -j$(nproc)
RUN make install

RUN export CC=/opt/gcc-10/bin/gcc
RUN export CXX=/opt/gcc-10/bin/g++
RUN export LDFLAGS="-Wl,-rpath,/opt/gcc-10/lib64"

RUN update-alternatives --install /usr/bin/gcc gcc /opt/gcc-10/bin/gcc 100
RUN update-alternatives --install /usr/bin/g++ g++ /opt/gcc-10/bin/g++ 100

WORKDIR /root
RUN export pfx="/root/local"
RUN mkdir -p "$pfx"

RUN git clone https://github.com/qt/qt5.git source
WORKDIR /root/source
RUN git checkout -f v5.15.7-lts-lgpl
RUN git submodule update --init --recursive
WORKDIR /root

RUN mkdir -p qt5-build
WORKDIR /root/qt5-build
RUN ../source/configure -opensource -nomake examples -nomake tests -confirm-license -prefix "$pfx/qt5" -skip qtconnectivity -skip qtandroidextras -skip qtpurchasing -skip qtserialbus -skip qtserialport -skip qtcharts -skip qtcanvas3d -skip qt3d -skip qtwebview -skip qtvirtualkeyboard -skip qtcharts -skip qtsensors -skip qtdatavis3d -skip qtdocgallery -skip qtfeedback -skip qtlocation -skip qttools -skip qttranslations -skip qtwebsockets -skip qtspeech
RUN make -j $(nproc)
RUN make install
