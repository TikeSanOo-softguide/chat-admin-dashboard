FROM node:lts

WORKDIR /app

# Copy only dependency files first (better cache)
COPY package.json package-lock.json* ./

# Install dependencies (clean & strict)
RUN npm install

# Copy app source
COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host"]