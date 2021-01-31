FROM gitpod/workspace-full
                    
USER gitpod

WORKDIR /home/gitpod

RUN git clone https://github.com/flutter/flutter && \
    /home/gitpod/flutter/bin/flutter channel stable && \
    /home/gitpod/flutter/bin/flutter upgrade && \
    /home/gitpod/flutter/bin/flutter config --enable-web && \
    /home/gitpod/flutter/bin/flutter --version

ENV PUB_CACHE=/workspace/.pub_cache
ENV PATH="/home/gitpod/flutter/bin:$PATH"
