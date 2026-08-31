---
layout: page
title: Instinct JCAS
description: A configurable simulator for Joint Communication and Sensing (JCAS) networks on a toroidal domain — stochastic-geometry deployments, mobility, physical channel models, and Kalman-filter object tracking.
img: assets/img/jcas/network_voronoi.png
importance: 1
category: Research
related_publications: false
---

Link to the [`Github repo`](https://github.com/emanuelemengoli/instinct-jcas-simulator).
The simulator runs from the notebook [`main.ipynb`](https://github.com/emanuelemengoli/instinct-jcas-simulator/blob/main/main.ipynb) or as a [Streamlit](https://streamlit.io) web app (`simulator_interface.py`). Developed within the EU-funded [**INSTINCT** ](https://www.barkhauseninstitut.org/en/instinct-joint-sensing-and-communication-for-future-connectivity)project.

This project provides a configurable simulator for **Joint Communication and Sensing (JCAS)** networks defined on a **periodic (toroidal) spatial domain**. Base stations, mobile user equipments and sensing objects are placed on a rectangular flat torus, where a **Voronoi tessellation** defines cell coverage; the periodic geometry removes boundary effects and yields unbiased spatial statistics. Deployments are drawn from **Poisson or Binomial point processes**, with users and targets placed either uniformly or as a Gaussian cluster around the serving base station.

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/jcas/network_voronoi.png" title="JCAS network realization and Voronoi tessellation" alt="JCAS network realization and Voronoi tessellation" class="img-fluid rounded z-depth-1 bg-white p-2" %}
    </div>
</div>
<div class="caption">
    A single network realization on the flat torus — BS, UE and SO — with the induced Voronoi tessellation that defines cell coverage.
</div>

Communication is modelled through **Lindley queues** with SINR-dependent service rates, over either a **ray-traced channel** parameterised from a University of Oulu ray-tracing campaign or a **Rayleigh-fading power-law** model. User equipments and sensing objects move under stationary, **Gauss–Markov**, or **ρ-persistent random-walk** motion, and targets are tracked with **Kalman / Extended Kalman filters** for linear and radar-style (range, bearing, range rate) observations. Optional **sector beamforming** and a cyclic **TDD** communication/sensing schedule are supported.

The simulator reports **coupling metrics** — an *association ratio* `A(X, Y) = E[XY] / (E[X]·E[Y])` and the Pearson correlation, for the interference, SINR and queue-versus-covariance pairs — that quantify the trade-off between the communication and sensing functions sharing the same infrastructure. Two operation modes are available: a *captive* full large-scale simulation, and a *non-captive* single-track toy model that benchmarks JCAS tracking against a sensing-only baseline.

## Features

- Network generation via **Poisson or Binomial point processes**; UEs and sensing objects placed uniformly or as a Gaussian cluster.
- **Toroidal geometry** with Voronoi cell coverage; mobility, filtering, beamforming and handover logic are all periodic.
- Mobility models: **stationary**, **Gauss–Markov**, and **ρ-persistent random walk**.
- Two physical channel models: **ray-traced** (`rt`, Oulu campaign) and **Rayleigh-fading power-law** (`exponential`); more can be registered at run time.
- Communication over **Lindley queues** with SINR-dependent service rates.
- Sensing and tracking with **Kalman / Extended Kalman filters**; one-way or two-way (monostatic-radar) sensing gain.
- Optional **sector beamforming** and **TDD scheduling**.
- **Communication–sensing coupling metrics** (association ratios, Pearson correlations).

## Example output

Figures from a single captive-scenario run under the default (`exponential` channel) configuration, produced by `jcas_simulator.visualization`.

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/jcas/sinr_kde.png" title="Communication and sensing SINR KDE" alt="Communication and sensing SINR KDE" class="img-fluid rounded z-depth-1 bg-white p-2" %}
    </div>
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/jcas/covariance_trace_kde.png" title="Filter covariance-trace KDE" alt="Filter covariance-trace KDE" class="img-fluid rounded z-depth-1 bg-white p-2" %}
    </div>
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/jcas/workload_kde.png" title="Queue-workload KDE" alt="Queue-workload KDE" class="img-fluid rounded z-depth-1 bg-white p-2" %}
    </div>
</div>
<div class="caption">
    Kernel density estimates pooled across entities in the steady-state window: per-link communication and sensing SINR (the monostatic sensing return is far weaker than the communication link), the KF/EKF error-covariance trace <code>Tr(Σ)</code> used as the sensing-uncertainty metric, and the per-cell Lindley-queue workload.
</div>

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/jcas/filter_queue_association.png" title="Queue workload versus filter covariance trace, with association ratio" alt="Queue workload versus filter covariance trace, with association ratio" class="img-fluid rounded z-depth-1 bg-white p-2" %}
    </div>
</div>
<div class="caption">
    Per-base-station mean queue workload against mean filter covariance trace. The association ratio <code>A(W, Tr Σ) ≈ 1.006 &gt; 1</code>: communication congestion and sensing uncertainty co-increase weakly across the network.
</div>

## Usage

Requires Python 3.10+.

```bash
git clone https://github.com/emanuelemengoli/instinct-jcas-simulator.git
cd instinct-jcas-simulator
./setup.sh
source .venv/bin/activate
```

Then either launch the web app with `streamlit run simulator_interface.py`, or open `main.ipynb`.

Released under the MIT License.

## References

[1] J. Pyhtilä, J. Kokkoniemi, P. Sangi, N. Vaara and M. Juntti, "Ray Tracing Based Radio Channel Modelling Applied to RIS," in *WSA & SCC 2023; 26th International ITG Workshop on Smart Antennas and 13th Conference on Systems, Communications, and Coding*, 2023, pp. 1–6.

[2] [INSTINCT — Joint Sensing and Communication for Future Connectivity, Barkhausen Institut.](https://www.barkhauseninstitut.org/en/instinct-joint-sensing-and-communication-for-future-connectivity)
