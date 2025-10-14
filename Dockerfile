# ================================================================
# UST-SSM Dockerfile (v4, 2025-10-12)
# Author: Haifeng
# ================================================================
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# 设置工作路径
WORKDIR /workspace

# ------------------------------------------------
# 1️⃣ 系统依赖
# ------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl vim ca-certificates \
    python3 python3-pip python3-dev python3-venv \
    build-essential cmake ninja-build pkg-config libgl1-mesa-dev \
    libglib2.0-0 libxrender-dev libxext-dev libsm6 libjpeg-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------
# 2️⃣ Python 环境
# ------------------------------------------------
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    python -m pip install --upgrade pip setuptools wheel

# ------------------------------------------------
# 3️⃣ PyTorch 安装（CUDA 12.1 版本）
# ------------------------------------------------
RUN pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 \
    --index-url https://download.pytorch.org/whl/cu121

# ------------------------------------------------
# 4️⃣ Python 常用包（UST + PointGPT）
# ------------------------------------------------
RUN pip install \
    matplotlib numpy pyyaml scipy tqdm ipdb easydict h5py opencv-python \
    tensorboardX transforms3d termcolor timm==0.4.5 \
    open3d==0.17.0 pyyaml tqdm

# ------------------------------------------------
# 5️⃣ [Optional] 跳过 causal-conv1d（网络不稳定可后装）
# ------------------------------------------------
RUN echo "⚠️ Skipping causal-conv1d installation temporarily (manual install later)" && \
    echo "To install inside container: \
    git clone https://github.com/PhilWang/causal-conv1d.git && \
    cd causal-conv1d && TORCH_CUDA_ARCH_LIST='7.0 8.0 8.6+PTX' pip install ."

# ------------------------------------------------
# 6️⃣ 设置环境变量（避免 OOM，统一缓存路径）
# ------------------------------------------------
ENV TRANSFORMERS_CACHE=/Disk2/haifeng/.cache/huggingface
ENV TORCH_HOME=/Disk2/haifeng/.cache/torch
ENV HF_HOME=/Disk2/haifeng/.cache/huggingface
ENV MPLCONFIGDIR=/Disk2/haifeng/.cache/matplotlib
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------
# 7️⃣ 配置 pip 源（加速下载）
# ------------------------------------------------
RUN mkdir -p /root/.pip && echo "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple" > /root/.pip/pip.conf

# ------------------------------------------------
# 8️⃣ 默认命令
# ------------------------------------------------
CMD ["/bin/bash"]
