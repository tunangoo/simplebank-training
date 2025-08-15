# Docker Setup cho SimpleBank

Hướng dẫn sử dụng Docker Compose để chạy ứng dụng SimpleBank với PostgreSQL.

## Cấu trúc Docker

```
simplebank-training/
├── docker-compose.yml    # Cấu hình Docker Compose
├── Dockerfile           # Build image cho ứng dụng Go
├── .dockerignore        # Loại trừ file không cần thiết
└── db/migration/        # SQL migration files
```

## Services

### 1. PostgreSQL Database

- **Image**: `postgres:17-alpine`
- **Port**: `6002:5432`
- **Database**: `simple_bank`
- **User**: `root`
- **Password**: `secret`
- **Health Check**: Kiểm tra kết nối database

### 2. Go Application

- **Build**: Multi-stage Dockerfile
- **Port**: `6000:8080`
- **Dependencies**: PostgreSQL
- **Environment**: Tự động kết nối database

## Cách sử dụng

### 1. Khởi động tất cả services

```bash
make up
# hoặc
docker-compose up -d
```

### 2. Linting và Testing

```bash
# Chạy linting
make lint

# Kiểm tra linting (không sửa)
make lint-check

# Chạy tests
make test
```

### 2. Xem logs

```bash
# Tất cả services
make logs

# Chỉ ứng dụng Go
make logs-app

# Chỉ PostgreSQL
make logs-postgres
```

### 3. Build lại image

```bash
make build
# hoặc
docker-compose build
```

### 4. Dừng services

```bash
make down
# hoặc
docker-compose down
```

### 5. Dừng và xóa volumes

```bash
docker-compose down -v
```

## Truy cập ứng dụng

- **API Server**: http://localhost:8080

## Kết nối database

### Từ host machine

```bash
psql -h localhost -p 5432 -U root -d simple_bank
```

### Từ container

```bash
docker exec -it simplebank-postgres psql -U root -d simple_bank
```

## Migration

Database migration sẽ tự động chạy khi PostgreSQL container khởi động lần đầu tiên. Các file migration trong `db/migration/` sẽ được thực thi theo thứ tự.

## Environment Variables

Các biến môi trường được cấu hình trong `docker-compose.yml`:

- `DB_SOURCE`: Connection string cho PostgreSQL
- `SERVER_ADDRESS`: Địa chỉ server (0.0.0.0:8080)
- `TOKEN_SYMMETRIC_KEY`: Key cho JWT token
- `ACCESS_TOKEN_DURATION`: Thời gian token có hiệu lực

## Volumes

- `postgres_data`: Lưu trữ dữ liệu PostgreSQL
- `pgadmin_data`: Lưu trữ cấu hình pgAdmin

## Networks

- `simplebank-network`: Network riêng cho các services

## Troubleshooting

### 1. Port đã được sử dụng

```bash
# Kiểm tra port đang sử dụng
lsof -i :5432
lsof -i :8080
lsof -i :5050

# Dừng service đang sử dụng port
sudo kill -9 <PID>
```

### 2. Database không kết nối được

```bash
# Kiểm tra container status
docker-compose ps

# Kiểm tra logs PostgreSQL
docker-compose logs postgres

# Restart PostgreSQL
docker-compose restart postgres
```

### 3. Application không start

```bash
# Kiểm tra logs application
docker-compose logs app

# Rebuild image
docker-compose build app
docker-compose up -d app
```

## Development

### Chạy migration thủ công

```bash
# Kết nối vào container
docker exec -it simplebank-postgres psql -U root -d simple_bank

# Chạy migration
docker exec -it simplebank-postgres psql -U root -d simple_bank -f /docker-entrypoint-initdb.d/000001_init_schema.up.sql
```

### Debug application

```bash
# Xem logs real-time
docker-compose logs -f app

# Vào container
docker exec -it simplebank-app sh
```

## CI/CD Pipeline

Dự án sử dụng GitHub Actions để tự động hóa:

### 1. CI Workflow: `.github/workflows/ci.yml`

**Triggers:**

- Push vào `main` hoặc `develop` branch
- Pull Request vào `main` hoặc `develop` branch

**Jobs:**

1. **Setup**: Go 1.23.3, PostgreSQL 17
2. **Dependencies**: Download và verify Go modules
3. **Database**: Chạy migrations
4. **Testing**: Chạy unit tests
5. **Build**: Compile binary và Docker image (local)
6. **Artifacts**: Upload build artifacts

### 2. Release Workflow: `.github/workflows/release.yml`

**Triggers:**

- Tạo release mới trên GitHub
- Publish release

**Jobs:**

1. **Setup**: Docker Buildx
2. **Authentication**: Login Docker Hub
3. **Metadata**: Extract version tags
4. **Build & Push**: Build và push Docker image
5. **Artifacts**: Upload release info

**Docker Images:**

- Tự động tag theo version: `v1.0.0`, `v1.1.0`
- Push lên Docker Hub với namespace của bạn

### Chạy Pipeline Locally

```bash
# Linting
make lint

# Testing
make test

# Build
make build
```

## Production

Để deploy production, cần:

1. Thay đổi passwords và secrets
2. Sử dụng external database
3. Cấu hình SSL/TLS
4. Setup monitoring và logging
5. Sử dụng Docker secrets hoặc external secret management
