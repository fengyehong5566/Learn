# prometheus学习

# 架构图

![](D:\Program%20Files\marktext\images\2022-06-17-16-53-42-0932f898a5227c913f259e913bbbe766.jpg)



## 指标抓取

pull：由prometheus服务器定期去exporter端抓取

push：由exporter端push到 Pushgateway，然后prometheus定期去Pushgateway取数据



## 服务注册

被监控服务在 Prometheus 中是一个 Job 存在，被监控服务的所有实例在 Prometheus 中是一个 target 的存在，所以被监控服务的注册就是在 Prometheus 中注册一个 Job 和其所有的 target。



注册分为两类：

    静态注册：直接将服务的ip和端口配置到prometheus的yaml文件的scrape_configs下

    动态注册：在 Prometheus yaml 文件的 scrape_configs 配置下配置服务发现的地址和服务名，Prometheus 会去该地址，根据你提供的服务名动态发现实例列表，

以下是基于consul的服务发现

```yaml
- job_name: "node_export_consul"
  metrics_path: /node_metrics
  scheme: http
  consul_sd_configs:
    - server: localhost:8500   # consul地址
      services:
        - node_exporter  #服务名
```

注意：

  如果是动态注册，最好加上下面两个配置，静态注册指标拉去的路径会默认指定为metrics_path:/metrics，如果不加会报"INVALID" is not a valid start token. 

```yaml
metrics_path: /node_metrics
scheme: http
```



prometheus支持二十多种服务发现协议：

```textile
<azure_sd_config>
<consul_sd_config>
<digitalocean_sd_config>
<docker_sd_config>
<dockerswarm_sd_config>
<dns_sd_config>
<ec2_sd_config>
<openstack_sd_config>
<file_sd_config>
<gce_sd_config>
<hetzner_sd_config>
<http_sd_config>
<kubernetes_sd_config>
<kuma_sd_config>
<lightsail_sd_config>
<linode_sd_config>
<marathon_sd_config>
<nerve_sd_config>
<serverset_sd_config>
<triton_sd_config>
<eureka_sd_config>
<scaleway_sd_config>
<static_config>
```



## 更新配置

方法1：重启prometheus服务

方法2：

        a、在启动prometheus服务的时候，带上启动参数：--web.enable-lifecycle

        b、更新配置文件后

        c、通过post请求的方式，动态更新配置

                 curl -v --request POST  'https://localhost:9090/-/reload'

    原理：

        Prometheus 在 web 模块中，注册了一个 handler：

```go
if o.EnableLifecycle {
  router.Post("/-/quit", h.quit)
  router.Put("/-/quit", h.quit)
  router.Post("/-/reload", h.reload) // reload配置
  router.Put("/-/reload", h.reload)
}
```

通过h.reload 这个handler方法实现：这个handler就是往一个channel中发送一个信号：

```go
func (h *Handler) reload(w http.ResponseWriter, r *http.Request) {
  rc := make(chan error)
  h.reloadCh <- rc  // 发送一个信号到channe了中
  if err := <-rc; err != nil {
   http.Error(w, fmt.Sprintf("failed to reload config: %s", er
r), http.StatusInternalServerError)
  }
}

```

在main函数中回去监听这个channel，只要有监听到信号，就会做配置的reload，重新加载新配置到内存中：

```go
case rc := <-webHandler.Reload():
  if err := reloadConfig(cfg.configFile, cfg.enableExpandExternalLabels, cfg.tsdb.EnableExemplarStorage, logger, noStepSubqueryInterval, reloaders...); err != nil {
   level.Error(logger).Log("msg", "Error reloading config", "err", err)
   rc <- err
  } else {
   rc <- nil
  }
```



## prometheus的指标类型

prometheus的数据有三部分组成：

    指标名和指标标签集合：metric_name{label_name:xxx, ....}

    时间戳：当前时间序列的时间，单位毫秒

    样本值：当前监控指标的具体数值

如下：

```textile
# HELP  // HELP：这里描述的指标的信息，表示这个是一个什么指标，统计什么的
# TYPE  // TYPE：这个指标是什么类型的

<metric name>{<label name>=<label value>, ...} value
// 指标的具体格式，<指标名>{标签集合} 指标值
```



prometheus有 4 中不同类型的指标：

    counter（计数器）：只增不减，错误数等

    gauge（仪表盘）：有增有减，适用于统计磁盘，CPU等动态数值

    histogram（直方图）：是累积计数，观察到指标在各个不同的区间范围的分布情况，

    summary（摘要）：用来做统计分析的，直接存储的就是百分位数



histogram：

    Histogram 是累计直方图，即每一个桶的是只有上区间。如当我们统计请求时间大于2秒的数量是10000，请求时间大于1秒的是30000，大于1秒的30000条请求数量里包含大于2秒的那10000条请求，要想获取大于1秒小于2秒的数量需要使用减法。直方图中，还可以通过histogram_quantile函数求出百分位数，比如P50，P90，P99等数据

```textile
histogram和summary区别：
  1、Summary 直接存储的就是百分位数，histogram需要计算才能获取到百分位数。
  2、Summary 的百分位数是客户端计算好，不需要在 Prometheus 计算；
     histogram是通过内置函数 histogram_quantile 在 Prometheus 服务端计算求出；
```

    


