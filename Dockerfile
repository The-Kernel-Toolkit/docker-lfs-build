FROM debian:sid

# image info
LABEL description="Automated LFS build"
LABEL version="12.4-rc1"
LABEL maintainer="ETJAKEOC@gmail.com"

# LFS mount point
ENV LFS=/lfs

# Other LFS parameters
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV MAKEFLAGS="-j 4"

# set 1 to run tests; running tests takes much more time
ENV LFS_TEST=0

# set 1 to install documentation; slightly increases final size
ENV LFS_DOCS=0

# degree of parallelism for compilation
ENV JOB_COUNT=4

# loop device
ENV LOOP=/dev/loop2

# mount point of loop device, for creating the iso iamge
ENV LOOP_DIR=/image/loop

# inital ram disk size in KB
# must be in sync with CONFIG_BLK_DEV_RAM_SIZE
ENV IMAGE_SIZE=1000000

# output images
ENV IMAGE_RAM=/dist/lfs.ram
ENV IMAGE_BZ2=/dist/lfs.bz2
ENV IMAGE_ISO=/dist/lfs.iso
ENV IMAGE_HDD=/dist/lfs.hdd

# location of initrd tree
ENV INITRD_TREE=$LFS

# set bash as default shell
WORKDIR /bin
RUN rm sh && ln -s bash sh

# install required packages
RUN apt-get update && apt-get install -y \
    build-essential bison file gawk texinfo \
    wget sudo genisoimage gcc clang lld llvm binutils \
 && apt-get -q -y autoremove             \
 && rm -rf /var/lib/apt/lists/*

# create sources directory as writable and sticky
RUN mkdir -pv     $LFS/sources   \
 && chmod -v a+wt $LFS/sources   \
 && ln    -sv     $LFS/sources /

# create book directory as writable and sticky
RUN mkdir -pv     $LFS/book   \
 && chmod -v a+wt $LFS/book   \
 && ln    -sv     $LFS/book /

# create image directory as writable and sticky
RUN mkdir -pv     $LFS/image   \
 && chmod -v a+wt $LFS/image   \
 && ln    -sv     $LFS/image /

# Copy additional scripts and archives
COPY ["book/", "$LFS/book/"]
COPY ["image/", "$LFS/image/"]
COPY ["sources/", "$LFS/sources/"]
COPY ["sources/wget-list", "$LFS/sources/wget-list"]
COPY [ ".bash_profile", ".bashrc", "/root/" ]
RUN source /root/.bash_profile

# create tools directory and symlink
RUN mkdir -pv $LFS/tools   \
 && ln    -sv $LFS/tools /

# check environment
RUN $LFS/book/version-check.sh \
 && $LFS/book/library-check.sh

# change path to home folder as default
WORKDIR /home/lfs

# Download all sources
RUN /book/chapter-3.sh

# let's the party begin
ENTRYPOINT ["/book/book.sh"]
