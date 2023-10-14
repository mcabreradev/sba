ARG NODE_IMAGE=imbios/bun-node:18-alpine

FROM $NODE_IMAGE AS deps
WORKDIR /app

COPY package.json bun.lockb ./

# RUN yarn config set network-timeout 600000 -g
# RUN yarn install --frozen-lockfile
RUN bun install --frozen-lockfile

FROM $NODE_IMAGE AS builder
WORKDIR /app

COPY . .
COPY --from=deps /app/node_modules ./node_modules
ENV NEXT_TELEMETRY_DISABLED 1


# RUN yarn build
RUN bun run build


FROM $NODE_IMAGE AS runner

WORKDIR /app

ENV NODE_ENV production
ENV STORE_PATH /data/store.json
ENV FORCE_COLOR 1

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

RUN ["chmod", "+x", "/usr/local/bin/docker-entrypoint.sh"]

CMD ["node", "server"]
