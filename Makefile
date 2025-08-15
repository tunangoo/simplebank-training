# Docker Compose commands
up:
	docker-compose up -d

down:
	docker-compose down

build:
	docker-compose build

logs:
	docker-compose logs -f

logs-app:
	docker-compose logs -f app

logs-postgres:
	docker-compose logs -f postgres

# Linting commands
lint:
	go fmt ./...
	go vet ./...
	$(shell go env GOPATH)/bin/goimports -w .

lint-check:
	go fmt -n ./...
	go vet ./...
	$(shell go env GOPATH)/bin/goimports -d .

# Database commands (for local development)
postgres:
	docker run --name postgres17 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:17-alpine

createdb:
	docker exec -it postgres17 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres17 dropdb --username=root --owner=root simple_bank

migrate_up:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrate_next:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up 1

migrate_down:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

migrate_previous:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down 1

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/godhitech/simplebank-training/db/sqlc Store

.PHONY: up down build logs logs-app logs-postgres lint lint-check postgres createdb dropdb migrate_up migrate_next migrate_down migrate_previous sqlc test server mock
