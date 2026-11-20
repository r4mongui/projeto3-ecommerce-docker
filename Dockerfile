FROM node:22-alpine
RUN apk add --no-cache openssl
WORKDIR /app
COPY package.json package-lock.json ./
RUN PRISMA_SKIP_POSTINSTALL_GENERATE=1 npm ci
COPY . .
RUN npm run prisma:generate && npm run build
EXPOSE 3000
CMD ["npm", "start"]
