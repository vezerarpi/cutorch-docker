FROM debian:8.2

ENV NV_DRIV_SH http://uk.download.nvidia.com/XFree86/Linux-x86_64/352.63/NVIDIA-Linux-x86_64-352.63.run
#ENV CUDA_DEB_SH http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.0-28_amd64.deb
ENV CUDA_RUN http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/cuda_7.0.28_linux.run

RUN apt-get update              \
    && apt-get install -y       \
        cmake                   \
        curl                    \
        gfortran                \
        git-core                \
        g++>4.9              \
        libtie-persistent-perl  \
        libreadline-dev         \
        make                    \
        module-init-tools       \
        openssl                 \
        unzip                   \
        wget                    \
        libzmq3-dev             \
    && apt-get clean

# NVIDIA drivers & CUDA runtime
RUN cd /tmp && wget -nv $NV_DRIV_SH -O driver.run && \
               sh driver.run -s --no-kernel-module && \
               wget -nv $CUDA_RUN -O cuda.run && \
               sh cuda.run --toolkit --silent && \
               rm *

# cudnn6.5 from https://raw.githubusercontent.com/NVIDIA/nvidia-docker/master/ubuntu-14.04/cuda/7.0/runtime/cudnn2/Dockerfile
ENV CUDNN_DOWNLOAD_SUM 4b02cb6bf9dfa57f63bfff33e532f53e2c5a12f9f1a1b46e980e626a55f380aa
RUN curl -fsSL http://developer.download.nvidia.com/compute/redist/cudnn/v2/cudnn-6.5-linux-x64-v2.tgz -O && \
    echo "$CUDNN_DOWNLOAD_SUM cudnn-6.5-linux-x64-v2.tgz" | sha256sum -c --strict - && \
    tar -xzf cudnn-6.5-linux-x64-v2.tgz && \
    mv cudnn-6.5-linux-x64-v2/libcudnn.so* /usr/local/cuda/lib64 && \
    rm -rf cudnn-6.5-linux-x64-v2* && \
    ldconfig

# OpenBLAS
RUN git clone https://github.com/xianyi/OpenBLAS.git -b v0.2.15 /tmp/openblas && \
    cd /tmp/openblas && \
    make NO_AFFINITY=1 USE_OPENMP=1 DYNAMIC_ARCH=1 NUM_THREADS=8 && \
    make install && \
    cd /tmp && rm -r *

# Torch7
RUN git clone https://github.com/torch/distro.git /opt/torch && \
    cd /opt/torch && \
    ./install.sh -b && \
    ls | grep -v "^install$" | xargs rm -r && rm -r .git

# Extra Torch dependencies
RUN luarocks install hash
RUN luarocks install https://raw.githubusercontent.com/bshillingford/autobw.torch/master/autobw-scm-1.rockspec

# Setup paths
ENV PATH=/usr/local/cuda/bin:/opt/torch/install/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:/opt/torch/install/lib:${LD_LIBRARY_PATH}

CMD ["bash"]

