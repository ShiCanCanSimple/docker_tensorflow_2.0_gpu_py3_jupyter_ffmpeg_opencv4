FROM tensorflow/tensorflow:2.0.0rc0-gpu-py3-jupyter

MAINTAINER Shi Cancan <simple_scc@163.com>

WORKDIR /root

RUN apt-get install -y unzip --assume-yes apt-utils cmake nasm

# 安装 ffmpeg
#RUN git clone https://git.ffmpeg.org/ffmpeg.git
COPY FFmpeg-master.zip /root
RUN unzip -q FFmpeg-master.zip && \
	mv FFmpeg-master ffmpeg && \
	cd ffmpeg && \
	./configure --enable-shared && \
	make -j12 && \
	make install && \
	cd .. && \
	rm FFmpeg-master.zip && \
	rm -r ffmpeg

# 安装opencv gui依赖
# RUN apt-get install -y vtk7 libvtk7-dev

COPY tzdata-auto-install /root
RUN python /root/tzdata-auto-install "apt-get install -y gtk2.0 libgtk2.0-dev libcanberra-gtk-module"

# 安装opencv
#RUN git clone https://github.com/opencv/opencv.git
#RUN git clone https://github.com/opencv/opencv_contrib.git
COPY opencv-master.zip .
COPY opencv_contrib-master.zip .
RUN unzip -q opencv-master.zip && mv opencv-master opencv && \
	unzip -q opencv_contrib-master.zip && mv opencv_contrib-master opencv_contrib

WORKDIR /root/opencv

COPY cache.tar.gz .
RUN tar -xf cache.tar.gz
RUN mkdir build

WORKDIR /root/opencv/build

#RUN mkdir -p share/opencv4/testdata/cv/fac
#COPY face_landmark_model.dat /root/opencv/build/share/opencv4/testdata/cv/face
RUN cmake -G "Unix Makefiles" -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=ON -DWITH_LAPACK=OFF -DWITH_CUDA=OFF -DINSTALL_C_EXAMPLES=OFF -DINSTALL_PYTHON_EXAMPLES=OFF -DBUILD_DOCS=OFF -DWITH_FFMPEG=ON -DWITH_QT=OFF ..
RUN make -j12 && make install

WORKDIR /root
RUN rm opencv-master.zip && rm -r opencv
RUN rm opencv_contrib-master.zip && rm -r opencv_contrib

