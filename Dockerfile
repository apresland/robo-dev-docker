ARG cuda_version=9.0
ARG ubuntu_version=16.04

FROM nvidia/cudagl:${cuda_version}-devel-ubuntu${ubuntu_version}

RUN rm /etc/apt/sources.list.d/nvidia-ml.list && apt-get clean && apt-get update
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apt-utils \
  build-essential \
  gcc \
  g++ \
  gdb \
  gdbserver \
  openssh-server \
  clang \
  cmake \
  rsync \
  git \
  mesa-utils \
  libgl1-mesa-glx \
  libeigen3-dev \
  libgl1-mesa-dev \
  libglew-dev \
  libpython2.7-dev \
  libegl1-mesa-dev \
  libwayland-dev \
  libxkbcommon-dev \
  wayland-protocols \
  libglu1-mesa-dev \
  freeglut3-dev \
  mesa-common-dev

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# 22 for ssh server. 7777 for gdb server.
EXPOSE 22 7777

# Create dev user with password 'dev'
RUN useradd -ms /bin/bash dev
RUN echo 'dev:dev' | chpasswd

# get pangolin
WORKDIR /home/dev
RUN git clone https://github.com/stevenlovegrove/Pangolin.git

# install pangolin
WORKDIR /home/dev/Pangolin/build
RUN cmake ..
RUN make
RUN make install

# X11 forwarding
ENV DISPLAY :0
RUN export LIBGL_ALWAYS_INDIRECT=1

# Upon start, run ssh daemon
CMD ["/usr/sbin/sshd", "-D"]
