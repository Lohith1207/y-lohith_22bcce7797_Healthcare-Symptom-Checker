# Use the official Dart SDK image
FROM dart:stable-sdk AS build

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY backend/pubspec.* ./
RUN dart pub get

# Copy source code
COPY backend/ ./

# Build the application
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o server

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -r -s /bin/false appuser

# Set working directory
WORKDIR /app

# Copy the compiled binary
COPY --from=build /app/server .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/api/health || exit 1

# Run the application
CMD ["./server"]
