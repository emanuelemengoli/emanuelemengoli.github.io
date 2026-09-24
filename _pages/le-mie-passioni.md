---
layout: page
title: Le mie passioni
permalink: /le-mie-passioni/
description: Wine, travel, sport and life outside research.
nav: true
nav_order: 6
map: true
---

<style>
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
  .passions-toolbar {
    display: flex;
    justify-content: flex-end;
    margin-bottom: 0.75rem;
  }
  .passions-lang-toggle {
    font: inherit;
    font-size: 0.75rem;
    font-weight: 700;
    padding: 0.25rem 0.55rem;
    border: 1px solid var(--global-divider-color);
    border-radius: 4px;
    background: transparent;
    color: var(--global-text-color-light);
    cursor: pointer;
  }
  .passions-lang-toggle:hover {
    border-color: var(--global-theme-color);
    color: var(--global-theme-color);
  }
  .passions-lang-toggle[aria-busy="true"] {
    opacity: 0.55;
    cursor: progress;
  }
  .passions-section > .section-desc {
    max-width: 44rem;
    margin: 0 0 1.1rem;
    font-size: 0.95rem;
    color: var(--global-text-color-light);
  }
  .section-sub {
    margin: 2.75rem 0 0.4rem;
    padding-bottom: 0.4rem;
    border-bottom: 1px solid var(--global-divider-color);
    font-size: 1.15rem;
    font-weight: 500;
  }
  .wine-stats {
    margin: 0 0 0.8rem;
    font-size: 0.85rem;
    color: var(--global-text-color-light);
  }
  .wine-legend {
    display: flex;
    flex-wrap: wrap;
    gap: 0.3rem 0.9rem;
    margin: 0 0 0.7rem;
    padding: 0;
    list-style: none;
    font-size: 0.8rem;
    color: var(--global-text-color-light);
  }
  .wine-legend li {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
  }
  .wine-legend-dot {
    display: inline-block;
    width: 9px;
    height: 9px;
    border-radius: 50%;
  }
</style>

{% include wine_i18n.liquid %}
<div class="passions-toolbar">
  <button id="passions-lang-toggle" class="passions-lang-toggle no-tx" type="button">EN</button>
</div>

<section class="passions-section">
  <h2>
    <i class="fa-solid fa-wine-glass"></i><span class="no-tx">Degustando</span>
  </h2>
  <p class="section-desc">
    Una raccolta dei vini che ho degustato: esplorali sulla mappa o chiedimi un
    consiglio in base al piatto, alla regione o all'occasione.
  </p>

  {% include wine_finder.liquid %}

  <h3 class="section-sub">La mia mappa del vino</h3>
  {% assign _w = site.data.wines %}
  {% if _w and _w.size > 0 %}
    {% assign _regions = _w | map: "region" | compact | uniq %}
    {% assign _countries = _w | map: "country" | compact | uniq %}
    <p class="wine-stats">
      {{ _w.size }} {% if _w.size == 1 %}vino{% else %}vini{% endif %} ·
      {{ _regions.size }} {% if _regions.size == 1 %}regione{% else %}regioni{% endif %} ·
      {{ _countries.size }} {% if _countries.size == 1 %}paese{% else %}paesi{% endif %}
    </p>
  {% endif %}
  <ul id="wine-legend" class="wine-legend"></ul>

  {% include wine_map.liquid %}
</section>

<section class="passions-section">
  <h2>
    <i class="fa-solid fa-person-running"></i><span class="no-tx">Correndo</span>
  </h2>
  <p class="section-desc">
    Gare di corsa su strada, trail, skyrun, ultra e triathlon in Francia, Italia, Spagna,
    Svizzera e Austria — la lista si aggiorna da sola ogni mese. Esplorale sulla mappa
    o chiedimi di aiutarti a pianificare la tua stagione.
  </p>

  {% include race_finder.liquid %}

  <h3 class="section-sub">La mappa delle gare</h3>
  {% assign _r = site.data.races %}
  {% if _r and _r.size > 0 %}
    {% assign _countries_r = _r | map: "country" | compact | uniq %}
    {% assign _categories_r = _r | map: "category" | compact | uniq %}
    <p class="wine-stats">
      {{ _r.size }} {% if _r.size == 1 %}gara{% else %}gare{% endif %} ·
      {{ _categories_r.size }} {% if _categories_r.size == 1 %}categoria{% else %}categorie{% endif %} ·
      {{ _countries_r.size }} {% if _countries_r.size == 1 %}paese{% else %}paesi{% endif %}
    </p>
  {% endif %}
  <ul id="race-legend" class="wine-legend"></ul>

  {% include race_map.liquid %}
</section>

<!--
  Add another topic as its own <section class="passions-section">: an <h2> with an
  icon, a <p class="section-desc">, then the text / images / include for that topic.
-->
