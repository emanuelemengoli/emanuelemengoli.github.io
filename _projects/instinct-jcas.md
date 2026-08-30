---
layout: page
title: Instinct JCAS
description: A configurable simulator for Joint Communication and Sensing (JCAS) networks on a toroidal domain — stochastic-geometry deployments, mobility, physical channel models, and Kalman-filter object tracking.
img:
importance: 1
category: Research
related_publications: false
---

Link to the [`Github repo`](https://github.com/emanuelemengoli/instinct-jcas-simulator).
The simulator runs from the notebook [`main.ipynb`](https://github.com/emanuelemengoli/instinct-jcas-simulator/blob/main/main.ipynb) or as a [Streamlit](https://streamlit.io) web app (`simulator_interface.py`). Developed within the EU-funded [**INSTINCT** ](https://www.barkhauseninstitut.org/en/instinct-joint-sensing-and-communication-for-future-connectivity)project.

This project provides a configurable simulator for **Joint Communication and Sensing (JCAS)** networks defined on a **periodic (toroidal) spatial domain**. Base stations, mobile user equipments and sensing objects are placed on a rectangular flat torus, where a **Voronoi tessellation** defines cell coverage; the periodic geometry removes boundary effects and yields unbiased spatial statistics. Deployments are drawn from **Poisson or Binomial point processes**, with users and targets placed either uniformly or as Gaussian clusters.

Communication is modelled through **Lindley queues** with SINR-dependent service rates, over either a **ray-traced channel** parameterised from University of Oulu measurements or a **Rayleigh-fading power-law** model. Sensing objects move under stationary, **Gauss–Markov**, or constant-speed mobility, and are tracked with **Kalman / Extended Kalman filters** for linear and nonlinear observations. Optional **beamforming** and **TDD scheduling** are supported.

The simulator reports **coupling metrics** — association ratios and Pearson correlations — that quantify the trade-off between the communication and sensing functions sharing the same infrastructure.

## Features

- Network generation via **Poisson or Binomial point processes**; UEs and sensing objects placed uniformly or as Gaussian clusters.
- **Toroidal geometry** with Voronoi cell coverage, eliminating edge effects.
- Mobility models: **stationary**, **Gauss–Markov**, and **constant-speed** motion.
- Two channel models: **ray-traced** (Oulu measurements) and **Rayleigh-fading power-law**.
- Communication over **Lindley queues** with SINR-dependent service rates.
- Sensing and tracking with **Kalman / Extended Kalman filters**.
- Optional **beamforming** and **TDD scheduling**.
- **Communication–sensing coupling metrics** (association ratios, Pearson correlations).

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
