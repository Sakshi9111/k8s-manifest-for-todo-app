# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY src/ ./src
RUN npm run build

# Stage 2: Generate SBOM with Debug Info
FROM alpine:3.20 AS sbom
RUN apk add --no-cache curl ca-certificates bash jq && \
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin && \
    syft version

# Copy application files to scan
WORKDIR /scan/app
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src

# DEBUG: Show what we're scanning
RUN echo "=== Directory Structure ===" && \
    ls -la && \
    echo "" && \
    echo "=== Package.json exists? ===" && \
    cat package.json | head -20 && \
    echo "" && \
    echo "=== Node modules count ===" && \
    ls node_modules | wc -l

# Generate SBOM with syft native JSON format (not SPDX)
RUN echo "=== Generating SBOM ===" && \
    syft dir:. -o json=/scan/sbom.json --verbose && \
    echo "" && \
    echo "=== SBOM File Info ===" && \
    ls -lh /scan/sbom.json && \
    echo "" && \
    echo "=== SBOM Preview ===" && \
    head -50 /scan/sbom.json && \
    echo "" && \
    echo "=== Artifact Count ===" && \
    jq '.artifacts | length' /scan/sbom.json && \
    echo "" && \
    echo "=== Sample Packages ===" && \
    jq -r '.artifacts[0:5] | .[] | "  - " + .name + " (" + .version + ")"' /scan/sbom.json

# Stage 3: Final runtime image
FROM node:20-alpine
WORKDIR /app

# Copy application from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src

# Copy SBOM from sbom stage
COPY --from=sbom /scan/sbom.json ./sbom.json

# Add jq for validation
RUN apk add --no-cache jq && \
    ARTIFACT_COUNT=$(jq '.artifacts | length' /app/sbom.json 2>/dev/null || echo "0") && \
    echo "SBOM contains $ARTIFACT_COUNT packages in final image"

EXPOSE 3000
CMD ["node", "src/index.js"]
