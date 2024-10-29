---
layout: page
title: NOMA_net - dynamic wireless cellular network simulator.
description: Dynamic Bayesian Optimization for Improving the Performance of Cellular Networks.
img: assets/img/Noma_net/visual_biased_rndm_wdbo.png
importance: 1
category: Research
related_publications: false
---

Link to the [Github repo](https://github.com/emanuelemengoli/NOMA_cellular_network_simulator).
A detailed analysis of of the project, experimental results and future extensions is available in `Dynamic_Bayesian_Optimization_for_Improving_the_Performance_of_Cellular_Networks.pdf [1]`.
A toy notebook to run the simulation is available in `run.ipynb`.


The increasing complexity of wireless communication networks necessitates innovative approaches to enhance their efficiency and adaptability. This project investigates the application of Bayesian Optimization (BO) to optimize resource allocation in dynamic wireless cellular networks, specifically employing a Non-Orthogonal Multiple Access (NOMA) resource sharing mechanism. Given the challenges of evaluating performance through costly objective functions, traditional greedy search strategies can impede efficient decision-making processes. We test a novel algorithm, Wasserstein-Dynamic Bayesian Optimization ([W-DBO](https://arxiv.org/pdf/2405.14540)), tailored to cope with environments subjected to spatio-temporal dynamics.

The project report [1] outlines the technical framework of BO and NOMA, articulates the problem statement, and discusses the experimental methodology alongside comparative analyses of motion models used to shape user trajectories. Results are presented, and the implications of the findings are explored, paving the way for future research in optimizing wireless network performance amidst user mobility.


<!-- <div class="row">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/Noma_net/obj_comparison_biased_random_walk.png" title="Biased Random Walk." class="img-fluid rounded z-depth-1" %}
    </div>
</div>
<div class="caption">
    Biased Random Walk.
</div> -->

<div class="row justify-content-sm-center">
    <div class="col-sm mt-3 mt-md-0">
            {% include figure.liquid loading="eager" path="assets/img/Noma_net/obj_comparison_biased_random_walk.png" title="Biased Random Walk." class="img-fluid rounded z-depth-1" %}
        </div>
    </div>
    <div class="caption">
        Biased Random Walk.
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid path="assets/img/Noma_net/obj_comparison_random_waypoint.png" title="Random Waypoint." class="img-fluid rounded z-depth-1" %}
    </div>
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid path="assets/img/Noma_net/obj_comparison_hybrid_gmm.png" title="Hybrid-GMM." class="img-fluid rounded z-depth-1" %}
    </div>
</div>
<div class="caption">
    Objective function comparison between W- DBO (blue), Random pick (red) and Constant pick (green). $\alpha$-fairness = 1.
</div>


