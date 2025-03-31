# 使用Node.js 18作为基础镜像
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm ci

# 复制所有项目文件
COPY . .

# 构建前端应用
RUN npm run build

# 构建API服务
RUN npm run build:api

# 暴露API端口（默认3001）
EXPOSE 3001

# 启动应用
CMD ["npm", "run", "start"] 