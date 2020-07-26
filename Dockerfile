# Stage 0, "build-stage", based on Node.js, to build and compile the frontend
FROM node:12.18.2-alpine3.9 as build-stage
# Define the working directory of a Docker container
# Any RUN, CMD, ADD, COPY, or ENTRYPOINT command will be executed in the specified working directory.
WORKDIR /app
# Copy package.json to our working directory "app"
COPY package*.json /app/
# Run "npm install" to install all our dependencies we use
RUN npm install
# Copy all files and directories to our working directory "app"
COPY ./ /app/
# Run "npm run build" to build our app as a production mode
RUN npm run build

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM nginx:alpine
# Copy the default our nginx configuration to default nginx configuration
COPY /app/nginx/nginx.conf /etc/nginx/conf.d/default.conf
# Remove all default nginx html
RUN rm -rf /usr/share/nginx/html/*
# Copy the default /app/build provided by build-stage
COPY --from=build-stage /app/build/ /usr/share/nginx/html
# Expose port 3000 of our react to port 80 of nginx
EXPOSE 3000 80
# Turn off nginx background process (good for production)
ENTRYPOINT ["nginx", "-g", "daemon off;"]
