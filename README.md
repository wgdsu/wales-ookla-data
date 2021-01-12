# Internet speed data for wales     

### Ookla data

Ookla is a provider of a free internet speed test service. Ookla is used worldwide to perform broadband and mobile internet performance tests on home and personal devices. Recently Ookla have started publishing [quarterly information](https://www.speedtest.net/insights/blog/announcing-ookla-open-datasets/) at high resolution.

**Speed test variables**
* avg_d_kbps - average download speed (kb per sec)
* avg_u_kbps - average upload speed (kb per sec)
* tests - number of tests performed in the areas
* devices - number of distinct devices performing tests
* latency_ms - average latency in milliseconds

The datasets published are global and each quarter a dataset for mobile internet and broadband internet are made available.

### Wales data

This repo contains R code to download and filter data from the global datasets for Wales. This code will allow analysts to quickly extract data for Wales and get started with some visualisation code.

### Example - How to use

```{r}
#download default file and store in "./data/"
get_data()
```
The `get_data()` function can take 3 parameters to specify the cut of data you want.

* **type**
`fixed` - broadband dataset (*default*)
`mobile` - mobile internet dataset

* **year**
`2020` - data publications started in 2020 (*default*)

* **quarter**
`1` - Quarter 1 (*default*)
`2` - Quarter 2
`3` - Quarter 3
`4` - Quarter 4

These parameters can be passed as parameters. If a specific parameter isnt specified then the function will assume the default value.

```{r}
#download specific file
get_data(type ="mobile", year = "2020", quarter = "4")
```
