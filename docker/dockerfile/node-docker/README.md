cd node

docker build -t node-poc .

docker run -p 3000:3000 node-poc

docker ps


localhost:3000