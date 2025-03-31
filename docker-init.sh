#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}正在初始化 Simple Video Player Docker 环境...${NC}"

# 检查是否安装了Docker和docker-compose
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker未安装。请先安装Docker: https://docs.docker.com/get-docker/${NC}"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${YELLOW}警告: Docker Compose未安装或不是最新版本。${NC}"
    echo -e "${YELLOW}如果您使用的是旧版Docker，请尝试使用 'docker-compose' 命令。${NC}"
fi

# 提示用户选择数据库类型
echo -e "${YELLOW}请选择数据库类型:${NC}"
echo "1) MySQL (默认)"
echo "2) PostgreSQL"
read -p "请输入选择 [1]: " db_choice

if [ "$db_choice" = "2" ]; then
    compose_file="docker-compose.postgres.yml"
    echo -e "${GREEN}已选择 PostgreSQL 数据库${NC}"
else
    compose_file="docker-compose.yml"
    echo -e "${GREEN}已选择 MySQL 数据库${NC}"
fi

# 询问用户是否要自定义管理员密码
read -p "是否要设置自定义管理员密码? (y/n) [n]: " custom_password
if [ "$custom_password" = "y" ] || [ "$custom_password" = "Y" ]; then
    read -p "请输入管理员密码: " admin_password
    
    # 更新docker-compose文件中的管理员密码
    if [ -n "$admin_password" ]; then
        if [ "$(uname)" = "Darwin" ]; then  # macOS
            sed -i '' "s/ADMIN_PASSWORD=admin123/ADMIN_PASSWORD=$admin_password/g" $compose_file
        else  # Linux
            sed -i "s/ADMIN_PASSWORD=admin123/ADMIN_PASSWORD=$admin_password/g" $compose_file
        fi
        echo -e "${GREEN}已更新管理员密码${NC}"
    fi
fi

# 询问用户是否要自定义JWT密钥
read -p "是否要设置自定义JWT密钥 (推荐)? (y/n) [n]: " custom_jwt
if [ "$custom_jwt" = "y" ] || [ "$custom_jwt" = "Y" ]; then
    # 生成随机JWT密钥
    jwt_key=$(openssl rand -base64 32)
    if [ "$(uname)" = "Darwin" ]; then  # macOS
        sed -i '' "s/LOGIN_JWT_SECRET_KEY=your_secret_key/LOGIN_JWT_SECRET_KEY=$jwt_key/g" $compose_file
    else  # Linux
        sed -i "s/LOGIN_JWT_SECRET_KEY=your_secret_key/LOGIN_JWT_SECRET_KEY=$jwt_key/g" $compose_file
    fi
    echo -e "${GREEN}已生成并设置JWT密钥${NC}"
fi

# 构建和启动容器
echo -e "${GREEN}正在构建和启动容器...${NC}"
docker compose -f $compose_file up -d --build

# 等待服务启动
echo -e "${YELLOW}等待服务启动...${NC}"
sleep 10

# 输出访问信息
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Simple Video Player 已成功部署!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}访问地址:${NC}"
echo -e "  前端应用: http://localhost:8080"
echo -e "  API服务: http://localhost:3001"
echo -e "${YELLOW}管理员登录:${NC}"
echo -e "  管理地址: http://localhost:8080/admin"
echo -e "  管理员密码: ${admin_password:-admin123}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}常用命令:${NC}"
echo -e "  查看日志: docker compose -f $compose_file logs -f"
echo -e "  停止服务: docker compose -f $compose_file down"
echo -e "  重启服务: docker compose -f $compose_file restart"
echo -e "${GREEN}========================================${NC}" 