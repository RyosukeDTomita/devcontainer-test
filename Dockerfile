# DevContainer
FROM node:20-bullseye AS devcontainer
WORKDIR /app
COPY . .
RUN cd react-default-app && npm install
# devcontainer.jsonの"overrideCommand": trueによりコンテナが立ち上がった状態にしている。

# Build Image
FROM node:20-bullseye AS build
WORKDIR /app
COPY ./react-default-app .
RUN npm install && npm run build

# Product Image
FROM public.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-nginx:latest-al23

# Change owner to allow non-root users to start the service
USER root
RUN <<EOF
mkdir -p /var/log/nginx
chown -R nginx:nginx /var/log/nginx
touch /run/nginx.pid
chown -R nginx:nginx /run/nginx.pid
EOF

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

# Use 8080 instead of 80 to avoid the `nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)` when using ECS.
EXPOSE 8080
USER nginx
CMD ["nginx", "-g", "daemon off;"]
