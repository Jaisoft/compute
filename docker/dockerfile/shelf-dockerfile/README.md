# Shelf 


dart create -t server-shelf shelf-dockerfile

docker build -t shelf-dockerfile:latest .

docker run -p 8081:8081 shelf-dockerfile:latest myserver

curl http://0.0.0.0:8081

curl http://0.0.0.0:8081/test/

docker kill myserver

