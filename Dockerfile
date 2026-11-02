FROM node:24-alpine

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

COPY app/package.json ./
RUN npm install 

COPY app/ ./

USER node

EXPOSE 3000

CMD ["node", "index.js"]
