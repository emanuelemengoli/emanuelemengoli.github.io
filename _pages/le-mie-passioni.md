---
layout: page
title: Le mie passioni
permalink: /le-mie-passioni/
#description: A few things I enjoy beyond research.
nav: true
nav_order: 6
map: true
hide_header: true # keeps "Le mie passioni" in the navbar but hides the page's <h1>/description
---

<style>
  .passions-lead {
    font-size: 1.05rem;
    color: var(--global-text-color-light);
    max-width: 44rem;
    margin: 0.75rem 0 0.5rem;
  }
  .passions-section {
    margin-top: 2.25rem;
  }
  .passions-section > h2 {
    display: flex;
    align-items: center;
    gap: 0.55rem;
    margin: 0 0 0.6rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--global-divider-color);
    font-size: 1.5rem;
    font-weight: 500;
  }
  .passions-section > h2 i {
    color: var(--global-theme-color);
    font-size: 0.8em;
  }
  .passions-section > .section-desc {
    max-width: 44rem;
    margin: 0 0 1.1rem;
    font-size: 0.95rem;
    color: var(--global-text-color-light);
  }
</style>

<p class="passions-lead">
  A small corner for the things I enjoy outside research; wine, travel,
  sport and whatever else finds its way here over time.
</p>

<section class="passions-section">
  <h2><i class="fa-solid fa-wine-glass"></i>Degustando</h2>
  <p class="section-desc">
    A collection of wines I have tasted, mapped to the places where they are produced.
    Click on a bottle to discover the producer and my personal rating. The collection
    grows as I explore new regions, producers and bottles.
  </p>
  {% include wine_map.liquid %}
</section>

<!--
  Add another topic as its own <section class="passions-section">: an <h2> with an
  icon, a <p class="section-desc">, then the text / images / include for that topic.
-->
