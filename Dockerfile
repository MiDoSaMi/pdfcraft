# =============================================================================
# PDFCraft Production Dockerfile
# Multi-stage build for optimized image size
# =============================================================================

FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

COPY . .

ARG BASE_PATH=""
ENV BASE_PATH=$BASE_PATH
ENV DOCKER_BUILD=true

RUN npm run build

FROM nginx:1.25-alpine AS production

LABEL org.opencontainers.image.source="https://github.com/PDFCraftTool/pdfcraft"
LABEL org.opencontainers.image.description="PDFCraft - Professional PDF Tools, Free, Private & Browser-Based"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.title="PDFCraft"
LABEL org.opencontainers.image.vendor="PDFCraftTool"

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY security-headers.conf /etc/nginx/security-headers.conf

COPY --from=builder /app/out /website/pdfcraft

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]