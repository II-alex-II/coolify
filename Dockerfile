FROM node:16.13.2-alpine
WORKDIR /app
COPY package*.json .
RUN yarn install
COPY . .
RUN yarn build

FROM node:16.13.2-alpine
WORKDIR /app
RUN apk add --no-cache git openssh-client curl jq cmake

COPY --from=0 /app/docker-compose.yaml .
COPY --from=0 /app/build .
COPY --from=0 /app/package.json .
COPY --from=0 /app/node_modules ./node_modules
COPY --from=0 /app/prisma ./prisma

RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm@6
RUN curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz" | tar -xzvf - docker/docker -C . --strip-components 1 && mv docker /usr/bin/docker
RUN mkdir -p ~/.docker/cli-plugins/
RUN curl -SL https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
RUN chmod +x ~/.docker/cli-plugins/docker-compose

EXPOSE 3000
CMD ["yarn", "start"]

