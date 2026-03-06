FROM ubuntu:22.04

# 安装运行转换服务所需的最小依赖，降低构建失败率
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    curl \
    ca-certificates \
    fontconfig \
    fonts-wqy-zenhei \
    fonts-noto-cjk \
    libreoffice \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY pyproject.toml ./

# 创建requirements.txt文件
RUN echo "starlette==0.31.1" > requirements.txt && \
    echo "pydantic==2.5.3" >> requirements.txt && \
    echo "boto3==1.28.65" >> requirements.txt && \
    echo "minio==7.2.15" >> requirements.txt && \
    echo "loguru==0.7.0" >> requirements.txt && \
    echo "uvicorn==0.23.2" >> requirements.txt && \
    echo "aiohttp==3.8.5" >> requirements.txt && \
    echo "python-multipart==0.0.6" >> requirements.txt && \
    echo "python-dotenv==1.1.0" >> requirements.txt

# asyncio是Python标准库，不需要通过pip安装

# 直接使用pip安装依赖
RUN pip3 install -r requirements.txt

# 创建必要的目录
RUN mkdir -p /app/tmp /app/logs

# 复制应用代码
COPY main.py ./

# 设置环境变量（生产环境中应该使用更安全的方式注入这些值，如Docker Secrets或环境变量注入）
ENV S3_BUCKET_NAME=""
ENV S3_ACCESS_KEY_ID=""
ENV S3_SECRET_ACCESS_KEY=""
ENV S3_REGION="us-east-1"
ENV S3_ENDPOINT_URL=""
ENV PDF_EXPIRE_TIME="60"
ENV DOWNLOAD_URL_PREFIX=""

# 暴露服务端口
EXPOSE 7758

# 运行时确保有足够的权限创建和删除临时文件
RUN chmod -R 777 /app/tmp /app/logs

# 启动命令
CMD ["python3", "main.py"]

