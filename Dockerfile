# Use the full Node image to perform package install
FROM node:18-alpine AS builder
RUN apk add --no-cache \
    autoconf \
    libtool \
    make \
    g++ \
    automake \
    bash \
    libc6-compat \
    libjpeg-turbo-dev \
    libpng-dev \
    nasm

RUN mkdir /app
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

# Copy files required for package install
COPY package.json yarn.lock /app/
RUN yarn --pure-lockfile

# Copy the remaining assets and build the application
COPY . /app/
RUN yarn build

# Copy files from the build stage to the smaller base image
FROM nginx:mainline-alpine
WORKDIR /usr/src/app
COPY --from=builder /app/public /usr/share/nginx/html
EXPOSE 80
