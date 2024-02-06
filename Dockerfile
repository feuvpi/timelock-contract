FROM node:16

WORKDIR /app

COPY package*.json ./
RUN npm install -g truffle
RUN npm install

COPY . .

CMD ["truffle", "test"]
