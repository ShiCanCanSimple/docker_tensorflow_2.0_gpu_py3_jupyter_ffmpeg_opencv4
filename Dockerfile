# 构建环境
ARG TF_TAG=2.0.0rc0-gpu-py3-jupyter

FROM tensorflow/tensorflow:$TF_TAG AS Builder

MAINTAINER Shi Cancan <simple_scc@163.com>

WORKDIR /root

COPY tzdata-auto-install .
RUN python /root/tzdata-auto-install "apt-get install -y unzip --assume-yes apt-utils cmake nasm gtk2.0 libgtk2.0-dev libcanberra-gtk-module" && rm tzdata-auto-install


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


# 安装opencv
#RUN git clone https://github.com/opencv/opencv.git
#RUN git clone https://github.com/opencv/opencv_contrib.git
COPY opencv-master.zip .
COPY opencv_contrib-master.zip .
RUN unzip -q opencv-master.zip && mv opencv-master opencv && \
	unzip -q opencv_contrib-master.zip && mv opencv_contrib-master opencv_contrib

WORKDIR /root/opencv

COPY cache.tar.gz .
RUN tar -xf cache.tar.gz && mkdir build

WORKDIR /root/opencv/build

RUN cmake -G "Unix Makefiles" -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=ON -DWITH_LAPACK=OFF -DWITH_CUDA=OFF -DINSTALL_C_EXAMPLES=OFF -DINSTALL_PYTHON_EXAMPLES=OFF -DBUILD_DOCS=OFF -DWITH_FFMPEG=ON -DWITH_QT=OFF .. && \
	make -j12 && make install && \
	make clean
	
WORKDIR /root
RUN rm opencv-master.zip && rm -r opencv && \
	rm opencv_contrib-master.zip && rm -r opencv_contrib

# 打包
RUN ls -1R --color=never /usr/local/lib/*.so /usr/local/lib/*.so.*  /usr/local/lib/python3.6/dist-packages/cv2/*.py /usr/local/lib/python3.6/dist-packages/cv2/python-3.6/*.so | xargs tar -cvf /root/cv2.tar.gz


# 运行环境

FROM tensorflow/tensorflow:$TF_TAG

WORKDIR /root

COPY tzdata-auto-install .
RUN python tzdata-auto-install "apt-get install -y --assume-yes apt-utils gtk2.0  libcanberra-gtk-module" && rm tzdata-auto-install && apt-get clean && apt-get autoclean 

WORKDIR /
COPY --from=Builder /root/cv2.tar.gz .
RUN tar -xf cv2.tar.gz  && rm cv2.tar.gz && echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> /root/.bashrc

#COPY 会把链接拷贝成文件
#COPY --from=Builder /usr/local/lib/*.so /usr/local/lib/
#COPY --from=Builder /usr/local/lib/*.so.*  /usr/local/lib/
#COPY --from=Builder /usr/local/lib/python3.6/dist-packages/cv2 /usr/local/lib/python3.6/dist-packages/cv2



