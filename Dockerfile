FROM cuda7:0.1-nv352.63

# Torch7
RUN git clone https://github.com/torch/distro.git /opt/torch && \
    cd /opt/torch && \
    ./install.sh -b && \
    ls | grep -v "^install$" | xargs rm -r && rm -r .git

# Setup paths
ENV PATH=/opt/torch/install/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/torch/install/lib:${LD_LIBRARY_PATH}

# Extra Torch dependencies
RUN luarocks install hash && \
    luarocks install nngraph && \
    luarocks install optim && \
    luarocks install moses && \
    luarocks install underscore && \
    luarocks install json && \
    luarocks install yaml && \
    luarocks install https://raw.githubusercontent.com/bshillingford/autobw.torch/master/autobw-scm-1.rockspec
