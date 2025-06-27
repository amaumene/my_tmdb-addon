FROM alpine AS deps

RUN apk add --no-cache nodejs npm

WORKDIR /build

RUN wget https://raw.githubusercontent.com/mrcanelas/tmdb-addon/refs/heads/main/package-lock.json

RUN wget https://raw.githubusercontent.com/mrcanelas/tmdb-addon/refs/heads/main/package.json


RUN npm set prefix=/build

RUN npm install --omit dev --build-from-source

FROM alpine AS vite

RUN apk add --no-cache nodejs npm git

RUN git clone https://github.com/mrcanelas/tmdb-addon.git /build

WORKDIR /build

RUN npm install

RUN npm run build

FROM alpine

RUN apk add --no-cache nodejs

WORKDIR /app

COPY --from=deps /build /app

COPY --from=vite /build/addon ./addon

COPY --from=vite /build/dist ./dist

COPY --from=vite /build/public ./public

EXPOSE 1337

ENTRYPOINT ["node", "addon/server.js"] 
