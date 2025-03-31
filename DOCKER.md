# Docker 部署指南

本文档介绍如何使用 Docker 部署 Simple Video Player 应用。

## 快速开始

我们提供了一个简单的初始化脚本来帮助您快速启动应用：

```bash
# 添加执行权限
chmod +x docker-init.sh

# 运行初始化脚本
./docker-init.sh
```

初始化脚本将指导您完成整个设置过程，包括：
- 选择数据库类型 (MySQL 或 PostgreSQL)
- 设置管理员密码
- 生成安全的 JWT 密钥
- 构建和启动容器

## 手动部署

如果您想手动配置和部署，可以按照以下步骤进行：

### 1. 选择数据库类型

我们提供了两种数据库配置：

- MySQL (默认): 使用 `docker-compose.yml`
- PostgreSQL: 使用 `docker-compose.postgres.yml`

### 2. 配置环境变量

在启动前，您可以修改 docker-compose 文件中的环境变量：

```yaml
environment:
  - SQL_DSN=root:mysql_password@tcp(db:3306)/videoplayer  # MySQL 连接字符串
  # 或者
  - PG_CONNECTION_STRING=postgresql://postgres:postgres@db:5432/videoplayer  # PostgreSQL 连接字符串
  - API_PORT=3001                                         # API 服务端口
  - ADMIN_PASSWORD=admin123                               # 管理员密码
  - LOGIN_JWT_SECRET_KEY=your_secret_key                  # JWT 密钥，建议修改为随机值
  - NODE_ENV=production                                   # 环境模式
```

### 3. 构建和启动

使用以下命令构建和启动应用：

```bash
# MySQL
docker compose up -d --build

# 或 PostgreSQL
docker compose -f docker-compose.postgres.yml up -d --build
```

## 访问应用

部署成功后，您可以通过以下地址访问应用：

- 前端应用: http://localhost:8080
- API 服务: http://localhost:3001
- 管理后台: http://localhost:8080/admin

## 常用命令

```bash
# 查看日志
docker compose logs -f

# 停止服务
docker compose down

# 重新启动服务
docker compose restart

# 停止并移除数据卷（将删除所有数据）
docker compose down -v
```

## 数据持久化

数据存储在 Docker 卷中，确保数据持久化：

- MySQL: `mysql_data` 卷
- PostgreSQL: `postgres_data` 卷

如果需要备份数据，可以使用以下命令：

```bash
# MySQL 备份
docker exec -it simple-video-player_db_1 mysqldump -u root -p videoplayer > backup.sql

# PostgreSQL 备份
docker exec -it simple-video-player_db_1 pg_dump -U postgres videoplayer > backup.sql
```

## 自定义

### 自定义端口

如果需要更改默认端口，可以修改 docker-compose 文件中的端口映射：

```yaml
ports:
  - "自定义端口:3001"  # API 端口
  - "自定义端口:8080"  # 前端端口
```

### 使用现有数据库

如果您想使用现有的数据库而不是 Docker 中的数据库，只需更新环境变量中的连接字符串：

```yaml
environment:
  - SQL_DSN=user:password@tcp(your-db-host:3306)/database  # MySQL
  # 或
  - PG_CONNECTION_STRING=postgresql://user:password@your-db-host:5432/database  # PostgreSQL
```

然后修改 docker-compose 文件，移除 db 服务相关配置。 