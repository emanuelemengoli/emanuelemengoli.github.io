---
layout: page
title: NOMA_net - Dynamic Wireless Cellular Network Simulator.
description: Dynamic Bayesian Optimization for Improving the Performance of Cellular Networks.
img: assets/img/Noma_net/visual_biased_rndm_wdbo.png
importance: 1
category: Research
related_publications: false
---

Link to the [Github repo](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator).
A detailed analysis of of the project, experimental results and future extensions is available in the [`project report`](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator/blob/main/Dynamic_Bayesian_Optimization_for_Improving_the_Performance_of_Cellular_Networks.pdf) or alternatively in the [`slide deck presentation`](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator/blob/main/DBO_for_cellular_networks.pdf) for a more condensed visualization.
A toy notebook to run the simulation is available in [`run.ipynb`](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator/blob/main/project/run.ipynb).


The increasing complexity of wireless communication networks necessitates innovative approaches to enhance their efficiency and adaptability. This project investigates the application of Bayesian Optimization (BO) to optimize resource allocation in dynamic wireless cellular networks, specifically employing a Non-Orthogonal Multiple Access (NOMA) resource sharing mechanism. Given the challenges of evaluating performance through costly objective functions, traditional greedy search strategies can impede efficient decision-making processes. We test a novel algorithm, Wasserstein-Dynamic Bayesian Optimization ([W-DBO]) [2], tailored to cope with environments subjected to spatio-temporal dynamics.

The project report outlines the technical framework of BO and NOMA, articulates the problem statement, and discusses the experimental methodology alongside comparative analyses of motion models used to shape user trajectories. Results are presented, and the implications of the findings are explored, paving the way for future research in optimizing wireless network performance amidst user mobility.

### Objective function comparison between W-DBO (blue), Random pick (red), and Constant pick (green). &#945;-fairness = 1.

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
[2] [Bardou, Anthony, Patrick Thiran, and Giovanni Ranieri. "This Too Shall Pass: Removing Stale Observations in Dynamic Bayesian Optimization." arXiv preprint arXiv:2405.14540 (2024).](https://arxiv.org/pdf/2405.14540)

