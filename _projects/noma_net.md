---
layout: page
title: NOMA_net.
description: Dynamic Bayesian Optimization (DBO) for cellular networks power optimization. NOMA_net is wireless cellular network simulator using NOMA as resource sharing mechanism (RSM).
img: assets/img/Noma_net/visual_biased_rndm_wdbo.jpg
importance: 1
category: Research
related_publications: false
---

Link to the [Github repo](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator).
A detailed analysis of of the project, experimental results and future extensions is available in the [`project report`](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator/blob/main/Dynamic_Bayesian_Optimization_for_Improving_the_Performance_of_Cellular_Networks.pdf). For a concise overview, refer to the [`slide deck presentation`](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator/blob/main/DBO_for_cellular_networks.pdf).
A toy notebook to run the simulator is available in [`run.ipynb`](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator/blob/main/project/run.ipynb).


With increasing complexity in wireless communication networks, innovative strategies are needed to enhance their efficiency and adaptability. This project investigates Bayesian Optimization (BO) for resource allocation optimization in dynamic wireless cellular networks, specifically utilizing Non-Orthogonal Multiple Access (NOMA) as the resource-sharing approach. Traditional greedy search methods can hinder effective decision-making due to the high computational cost of performance evaluations. Our approach leverages a novel algorithm, Wasserstein-Dynamic Bayesian Optimization ([W-DBO]) [1], designed to adapt to environments subjected to spatio-temporal dynamics.

The project report details the technical framework of BO and NOMA, articulates the problem statement, and discusses the experimental setup, including a comparative analysis of motion models for user trajectory simulation. The results and their implications are explored, providing insights for future research in optimizing wireless network performance amid user mobility.

## Some experimental results...

<div style="font-size: 0.85em; font-weight: bold; color: #555;">
    Objective function comparison between W-DBO (blue), Random pick (red), and Constant pick (green). &#945;-fairness = 1.
</div>


<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/Noma_net/obj_comparison_biased_random_walk.png" title="Biased Random Walk." class="img-fluid rounded z-depth-1" %}
    </div>
</div>
<div class="caption">
    Biased Random Walk mobility model.
</div>

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/Noma_net/obj_comparison_random_waypoint.png" title="Random Waypoint." class="img-fluid rounded z-depth-1" %}
    </div>
</div>
<div class="caption">
    Random Waypoint mobility model.
</div>

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/Noma_net/obj_comparison_hybrid_gmm.png" title="Hybrid-GMM." class="img-fluid rounded z-depth-1" %}
    </div>
</div>
<div class="caption">
    Hybrid-GMM mobility model.
</div>


## References
[1] [Bardou, Anthony, Patrick Thiran, and Giovanni Ranieri. "This Too Shall Pass: Removing Stale Observations in Dynamic Bayesian Optimization." arXiv preprint arXiv:2405.14540 (2024).](https://arxiv.org/pdf/2405.14540)

