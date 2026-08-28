---
layout: page
title: Le mie passioni
permalink: /le-mie-passioni/
#description: A few things I enjoy beyond research.
nav: true
nav_order: 6
map: true
---

<style>
  .passions-lead {
    font-size: 1.05rem;
    color: var(--global-text-color-light);
    max-width: 44rem;
    margin: 0.75rem 0 0.5rem;
  }
  .passions-card {
    border: none;
    border-left: 3px solid var(--global-theme-color);
    border-radius: 10px;
    padding: 1.4rem 1.5rem;
    margin-top: 1.75rem;
    background: var(--global-card-bg-color);
    box-shadow: 0 3px 14px rgba(0, 0, 0, 0.07);
  }
  html[data-theme="dark"] .passions-card {
    box-shadow: 0 3px 14px rgba(0, 0, 0, 0.4);
  }
  .passions-card .card-title {
    display: flex;
    align-items: center;
    gap: 0.55rem;
    margin: 0 0 0.9rem;
    padding-bottom: 0.6rem;
    border-bottom: 1px solid var(--global-divider-color);
    font-size: 1.15rem;
  }
  .passions-card .card-title i {
    color: var(--global-theme-color);
    font-size: 0.95em;
  }
  .passions-card > p {
    margin-bottom: 1rem;
    color: var(--global-text-color);
  }
</style>

<p class="passions-lead">
  A small corner of the website for the things I enjoy outside research — wine, travel,
  sport, and whatever else finds its way here over time.
</p>

<div class="card passions-card">
  <h3 class="card-title font-weight-medium"><i class="fa-solid fa-wine-glass"></i>Degustando</h3>
  <p>
    A collection of wines I have tasted, mapped to the places where they are produced.
    Click on a bottle to discover the producer and see my personal rating. The collection
    grows as I explore new regions, producers, and bottles.
  </p>
  {% include wine_map.liquid %}
</div>

<!--
  Add another topic as its own card: copy the block above, swap the icon and the
  <h3>, and put the text / images / include for that topic inside the div.
-->
