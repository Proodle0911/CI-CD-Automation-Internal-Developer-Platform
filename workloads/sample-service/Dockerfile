# Stage 1: Build
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy and download dependencies
COPY go.mod ./
# COPY go.sum ./ # Uncomment when go.sum exists
RUN go mod download

# Copy source code
COPY . .

# Build the binary with security flags
# CGO_ENABLED=0 for a static binary, -ldflags="-w -s" to shrink size
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main ./cmd/main.go

# Stage 2: Runtime
FROM gcr.io/distroless/static:latest

WORKDIR /

# Copy the binary from the builder stage
COPY --from=builder /app/main /main

# Expose port
EXPOSE 8080

# Use a non-root user (distroless has 'nonroot' user by default)
USER nonroot:nonroot

# Run the binary
ENTRYPOINT ["/main"]
