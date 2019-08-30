# 构建命令

```
sudo docker build -t "simplescc/vision:tf2_gpu_py3_jupyter_cv4_ffmpeg" .
```

# 运行命令

```
sudo docker run --gpus all -e DISPLAY=:0 -v /tmp/.X11-unix:/tmp/.X11-unix  -p 8888:8888 -h 0.0.0.0 simplescc/vision:tf2_gpu_py3_jupyter_cv4_ffmpeg
```

# 包含的组件

tensorflow 2.0.0rc0 GPU

python3.6

jupyter

opencv 4.1.1 with ffmpeg


