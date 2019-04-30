# How to use this image?
## following step if use **docker compose** .
----
### 1. Prepare your own **config.json** file .
### 2. Code **compose** file like this:

```
version: "3.2"
services:
  yapi-web:
    image: flyceek/alpine-yapi:latest
    ports:
      - "3003:3000"
    volumes:
      - /var/yapi/config.json:/opt/yapi/config.json
    links:
      - mongodb
    networks:
      - yapi-net
    depends_on:
      - mongodb
      - mongo-express
    restart: always
  mongodb:
    image: mongo
    ports:
      - "27018:27017"
    volumes:
      - yapi-mongodb:/data/db
    networks:
      - yapi-net
  mongo-express:
    image: mongo-express
    links:
      - mongodb
    ports:
      - "18124:8081"
    environment:
      ME_CONFIG_MONGODB_PORT: 27017
      ME_CONFIG_MONGODB_SERVER: mongodb
    networks:
      - yapi-net
    depends_on:
      - mongodb
    restart: always
networks:
  yapi-net:
volumes:
  yapi-mongodb:
``` 
### warning
   - **config.json** file mount.
   - **port** settings.

### 3. Start or Stop.
   1.  input **docker-compose -f**  *COMPOSE-FILE-PATH*  **up -d** cmd to start up.
   2.  input **docker-compose -f**  *COMPOSE-FILE-PATH* **down** cmd to stop
