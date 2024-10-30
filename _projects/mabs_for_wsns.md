---
layout: page
title: MABs for WSNs routing.
description: Relaxing the single-hop constraint to enable multi-hop routing via Multi-Armed Bandits (MABs). Wireless Sensor Networks (WSNs).
img: assets/img/WSN_MABS_experimets_images/random_net.jpg
importance: 1
category: Research
related_publications: false
---

Link to the [Github repo](https://github.com/emanuelemengoli/MABs-Dynamic-Routing-WSNs).
A detailed analysis of of the project, experimental results and future extensions is available in [`project report`](https://github.com/emanuelemengoli/MABs-Dynamic-Routing-WSNs/blob/main/Sensor_Networks_Dynamical_routing_adaptation_via_MABs.pdf).
The code is available in [`toy_test.ipynb`](https://github.com/emanuelemengoli/MABs-Dynamic-Routing-WSNs/blob/main/toy_test.ipynb).

This project focuses on single-hop WSNs, in particular how the inherent `single-hop constraint` can be relaxed to enable `multi-hop routing`. The underlying objective is extending the current geographic coverage limits of WSNs, imposed by the single-hop to gateway constraint, to larger geographic areas where end-nodes route packets to an available gateway. 
The proposed approach leverages `MABs` to build an `adaptive dynamic routing mechanism`. This contribution constitutes the project work for the class `INF567 - Wireless networks: from cellular to connected objects` at `École Polytechnique`. 

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/WSN_MABS_experimets_images/random_net.png" title="Random network topology." class="img-fluid rounded z-depth-1" %}
    </div>
</div>
<div class="caption">
    Random network topology.
</div>

<div class="row justify-content-sm-center">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid path="assets/img/WSN_MABS_experimets_images/deadlock_rate_ucb_random.png" title="Deadlock analysis on random network topology - UCB routing strategy." class="img-fluid rounded z-depth-1" %}
    </div>
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid path="assets/img/WSN_MABS_experimets_images/metrics_random_net_ucb" title="Performance metrics on random network topology - UCB routing strategy." class="img-fluid rounded z-depth-1" %}
    </div>
</div>
<div class="caption">
    Performance analysis of UCB routing strategy over random network topologies.
</div>


