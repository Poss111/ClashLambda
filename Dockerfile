FROM amazon/aws-lambda-nodejs:14
WORKDIR /usr/src/app
COPY index.js package*.json ./
RUN npm install
CMD [ "index.handler" ]
