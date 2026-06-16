const express = require("express");
const redis = require("redis");

const app = express();

const client = redis.createClient({
  host: "redis-server",
});

client.set("visits", 0);

app.get("/", (req, res) => {
  client.get("visits", (err, visits) => {
    if (err) {
      return res.status(500).send("Error fetching data from redis");
    }
    res.send(`Number visitors today: ${visits}`);

    client.set("visits", parseInt(visits) + 1);
  });
});

app.listen(8081, () => {
  console.log("Listening on port 8081");
});
