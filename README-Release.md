# Release Workflow

Workflow này sẽ tự động build và push Docker image khi có release version.

## Trigger

Workflow sẽ chạy khi:

- Tạo release mới trên GitHub
- Publish release

## Cấu hình Secrets

Cần thiết lập các secrets sau trong GitHub repository:

### 1. DOCKER_USERNAME

- Username Docker Hub của bạn
- Ví dụ: `yourusername`

### 2. DOCKER_PASSWORD

- Password hoặc access token Docker Hub
- **Lưu ý**: Nên sử dụng Docker Hub access token thay vì password

## Cách tạo Docker Hub Access Token

1. Đăng nhập vào [Docker Hub](https://hub.docker.com/)
2. Vào **Account Settings** → **Security**
3. Click **New Access Token**
4. Đặt tên và chọn quyền **Read & Write**
5. Copy token và lưu vào GitHub secrets

## Cách tạo Release

### 1. Tạo Release trên GitHub

```bash
# Tạo tag (đảm bảo format: vX.Y.Z)
git tag v1.0.0

# Push tag
git push origin v1.0.0
```

**Lưu ý về tag format:**

- Sử dụng format semantic versioning: `v1.0.0`, `v1.1.0`
- Không sử dụng dấu `-` ở đầu: `-v1.0.0` ❌
- Không sử dụng underscore: `v1_0_0` ❌
- Format đúng: `v1.0.0` ✅

### 2. Tạo Release trên GitHub

- Vào **Releases** tab
- Click **Create a new release**
- Chọn tag vừa tạo
- Điền title và description
- Click **Publish release**

## Docker Image Tags

Workflow sẽ tự động tạo các tags:

- **Version tag**: `v1.0.0`, `v1.1.0`
- **Major.Minor**: `v1.0`, `v1.1`
- **Latest**: `latest` (chỉ khi push vào default branch)

## Ví dụ Tags

```
yourusername/simplebank:v1.0.0
yourusername/simplebank:v1.0
yourusername/simplebank:latest
```

## Pull Docker Image

```bash
# Pull latest version
docker pull yourusername/simplebank:latest

# Pull specific version
docker pull yourusername/simplebank:v1.0.0

# Run container
docker run -p 6000:8080 yourusername/simplebank:latest
```

## Troubleshooting

### 1. Workflow không chạy

- Kiểm tra secrets đã được thiết lập
- Đảm bảo release được publish (không phải draft)

### 2. Docker login failed

- Kiểm tra DOCKER_USERNAME và DOCKER_PASSWORD
- Đảm bảo access token có quyền Read & Write

### 3. Build failed

- Kiểm tra Dockerfile có lỗi gì không
- Xem logs trong GitHub Actions

### 4. Invalid tag format

- Đảm bảo tag Git có format hợp lệ: `v1.0.0`, `v1.1.0`
- Không sử dụng dấu `-` ở đầu tag
- Tag phải bắt đầu bằng chữ cái hoặc số

## Local Testing

Để test Docker build locally:

```bash
# Build image
docker build -t simplebank:test .

# Run container
docker run -p 6000:8080 simplebank:test

# Test API
curl http://localhost:6000/accounts
```
