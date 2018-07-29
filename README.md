# ExMiner

A tool used for dynamically clustering datasets, currently only supports kmean algorithm.

## How ExMiner works

In ExMiner, each data cluster is represented by a worked registered in a worker registry. While starting the program, data in the generated dataset is assigned equally into each cluster, the clusters will then do the necessary calculation, process the data one by one and ask the other workers in the pool (in a round-robin fashion) to take over the data if the data belongs to another cluster. ExMiner is using Mnesia for storing processed dataset and the centroids (or other metadata) of each cluster. Currently ExMiner only supports kmean algorithm.

Clusters can be visualised by using [ex_miner_frontend](https://github.com/fdfzcq/ex_miner_frontend)

To run the program locally:

If you have Elixir installed, simply run iex, but remember to remove the Mnesia table each time:

```bash
iex -S mix
```

If you are a docker player and prefer a clean sheet, do:

```bash
make run-docker
```

## API endpoints:

Default port: 8990

```
/clusterData: POST | start generating dataset and grouping data into clusters
```
response: {success: true} | error

options:
- {cluster_n: int()} number of data clusters, default by 3
- {dataset_size: int()} size of dataset to group, default by 500
- {data_range: int()} range of data values starting from 0, default by 1000
- {cluster_interval: milliseconds()} processing interval, each cluster will start processing the next data after these many milliseconds
- {algorithm: algorithm()} currently only supports kmean

```
/getData: GET | get all data
```
response example: {data: [[[1, 2], 1], [[2, 3], 2]]} #{data: [[[x, y], group], ...]}
