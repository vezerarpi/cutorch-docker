FROM debian:8.2
MAINTAINER Arpi Vezer <arpi.vezer@gmail.com>

ENV NV_DRIV_SH http://uk.download.nvidia.com/XFree86/Linux-x86_64/352.63/NVIDIA-Linux-x86_64-352.63.run
ENV CUDA_DEB_SH http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.0-28_amd64.deb
ENV CUDA_RUN http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/cuda_7.0.28_linux.run

RUN apt-get -y update && apt-get install -y \
    build-essential \
    ca-certificates \
    cmake \
    'g++-4.9' \
    gfortran \
    git-core \
    libreadline-dev \
    libtie-persistent-perl \
    make \
    module-init-tools \
    unzip \
    wget \
    && apt-get clean

# NVIDIA drivers & CUDA runtime
RUN cd /tmp && \
    wget -nv $NV_DRIV_SH -O driver.run && \
    sh driver.run -s --no-kernel-module

RUN cd /tmp && \
    wget -nv $CUDA_RUN -O cuda.run && \
    sh cuda.run --toolkit --silent && \
    rm *

#RUN wget -nv $CUDA_DEB_SH -O cuda.deb && \
#dpkg -i cuda.deb && apt-get update && \
#apt-get install -y cuda-toolkit-7-0 && \
#rm *

ENV CUDA_HOME=/usr/local/cuda-7.0
#ENV CUDA_BIN_PATH=CUDA_HOME
#ENV CUDA_TOOLKIT_ROOT_DIR=CUDA_HOME
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64 
ENV PATH=${CUDA_HOME}/bin:${PATH} 

# OpenBLAS
RUN git clone https://github.com/xianyi/OpenBLAS.git -b v0.2.15 /tmp/openblas && \
    cd /tmp/openblas && \
    make NO_AFFINITY=1 USE_OPENMP=1 DYNAMIC_ARCH=1 NUM_THREADS=8 && \
    make install && \
    cd /tmp && rm -r *

# Torch7
RUN git clone https://github.com/torch/distro.git /opt/torch && \
    cd /opt/torch
#./install.sh -b
#ls | grep -v "^install$" | xargs rm -r && rm -r .git

CMD ["bash"]

