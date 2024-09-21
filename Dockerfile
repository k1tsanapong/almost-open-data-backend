# Creating multi-stage build for production
FROM node:18-alpine as build

RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1
ENV NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/
COPY package.json yarn.lock ./
RUN yarn global add node-gyp
RUN yarn config set network-timeout 600000 -g && yarn install --production
ENV PATH=/opt/node_modules/.bin:$PATH
WORKDIR /opt/app
COPY . .
RUN yarn build

# Creating final production image
FROM node:18-alpine

# Declare all build arguments
ARG HOST
ARG PORT
ARG APP_KEYS
ARG API_TOKEN_SALT
ARG ADMIN_JWT_SECRET
ARG TRANSFER_TOKEN_SALT
ARG DATABASE_CLIENT
ARG DATABASE_HOST
ARG DATABASE_PORT
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD
ARG DATABASE_SSL
ARG JWT_SECRET

# Set environment variables using the build arguments
ENV HOST=$HOST
ENV PORT=$PORT
ENV APP_KEYS=$APP_KEYS
ENV API_TOKEN_SALT=$API_TOKEN_SALT
ENV ADMIN_JWT_SECRET=$ADMIN_JWT_SECRET
ENV TRANSFER_TOKEN_SALT=$TRANSFER_TOKEN_SALT
ENV DATABASE_CLIENT=$DATABASE_CLIENT
ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_PORT=$DATABASE_PORT
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USERNAME=$DATABASE_USERNAME
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD
ENV DATABASE_SSL=$DATABASE_SSL
ENV JWT_SECRET=$JWT_SECRET


RUN apk add --no-cache vips-dev
ENV NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
WORKDIR /opt/
COPY --from=build /opt/node_modules ./node_modules
WORKDIR /opt/app
COPY --from=build /opt/app ./
ENV PATH=/opt/node_modules/.bin:$PATH

RUN chown -R node:node /opt/app
USER node
EXPOSE 1337
CMD ["yarn", "start"]