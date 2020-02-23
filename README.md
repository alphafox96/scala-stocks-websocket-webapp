# play-scala-YahooFinance-websocket

## Overview

This simple web app provides a graph for each desired stock, visualizing real-time stock prices. The YahooFinanceAPI is queried every 500 ms for each stock. The graph has 50 historical datapoints on it at any given time, providing a visualization of each stocks variability over a 25 second sliding window.

The Websocket API is built on Akka Streams, and so is async, non-blocking, and backpressure aware.

## Running the app

Make sure sbt is downloaded on your machine (https://www.scala-sbt.org/download.html). Navigate to the root directory of this repo and run `sbt`. Once the sbt console is up, run `compile`, then `run`. Navigate to localhost:9000 in your browser to see the app.
