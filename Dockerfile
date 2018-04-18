FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y locales

# ubuntu docker images don't set up a sensible locale, so we gotta do
# this to avoid some errors about improper encodings and whatnot
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install some important build tools
RUN apt-get install -y build-essential
RUN apt-get install -y python
RUN apt-get install -y git
RUN apt-get install -y cmake
RUN apt-get install -y curl

# this will be the target we're building
ENV TGT=x86_64-sel4-robigalia

# grab the sources
RUN git clone https://github.com/aisamanra/rust.git  /opt/rust
# make sure we have target descriptions for the new targets
RUN mkdir /opt/targets
RUN cd /opt/targets && curl -O https://raw.githubusercontent.com/GaloisInc/rs_seL4_tools/master/common-tool/x86_64-sel4-robigalia.json
RUN cd /opt/targets && curl -O https://raw.githubusercontent.com/GaloisInc/rs_seL4_tools/master/common-tool/i686-sel4-robigalia.json
RUN cd /opt/targets && curl -O https://raw.githubusercontent.com/GaloisInc/rs_seL4_tools/master/common-tool/arm-sel4-robigalia.json
ENV RUST_TARGET_PATH=/opt/targets
# and run the builf!
RUN cd /opt/rust && ./x.py build --target=$TGT

# fetch the rlibs needed to assemble the sysroots into a single tarball
RUN cd /opt/rust/build/x86_64-unknown-linux-gnu/stage2/ && \
    tar -cf /opt/$TGT.tar.gz lib/rustlib/$TGT/lib/*.rlib

# and grab the compiler needed
RUN cd /opt/rust/build/x86_64-unknown-linux-gnu/stage2/ && \
    tar -cf /opt/rust.tar.gz bin/* lib/*.so
