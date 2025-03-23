FROM mcr.microsoft.com/devcontainers/typescript-node:22-bookworm AS dependencies
WORKDIR /app/

COPY ./react-app/package.json ./react-app/yarn.lock ./
RUN yarn install --production=true && yarn cache clean

COPY . .
RUN cd react-app && yarn build

FROM dependencies AS devcontainer

# Product Image
FROM public.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-nginx:latest-al23 AS deploy

# Change owner to allow non-root users to start the service
USER root
RUN <<EOF bash -ex
mkdir -p /var/log/nginx
chown -R nginx:nginx /var/log/nginx
touch /run/nginx.pid
chown -R nginx:nginx /run/nginx.pid
EOF

COPY --from=devcontainer /app/react-app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

# Use 8080 instead of 80 to avoid the `nginx: [emerg] bind() to 0#.0.0.0:80 failed (13: Permission denied)` when using ECS.
EXPOSE 8080
USER nginx
CMD ["nginx", "-g", "daemon off;"]

