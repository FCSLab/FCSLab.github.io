---
layout: page
title: Program by Track
description: Every accepted contribution, grouped by track.
permalink: /program-by-track/
---

{% comment %}
  A flat, searchable listing of everything in the programme, grouped by the
  `track` column of _data/proceedings.csv. This is the page attendees use to
  find one specific paper or work, so it deliberately puts every title on a
  single page rather than paginating.

  Track order and display names come from `site.tracks` in _config.yml when it
  is set; otherwise tracks are derived from the data and sorted alphabetically.
{% endcomment %}

{% if site.tracks %}
  {% assign tracks = site.tracks %}
{% else %}
  {% assign track_keys = "" | split: "" %}
  {% for entry in site.data.proceedings %}
    {% if entry.track and entry.track != "" %}
      {% unless track_keys contains entry.track %}
        {% assign track_keys = track_keys | push: entry.track %}
      {% endunless %}
    {% endif %}
  {% endfor %}
  {% assign track_keys = track_keys | sort %}
{% endif %}

<p>Jump to:
  {% if site.tracks %}
    {% for track in tracks %}
    <a href="#{{ track.key }}">{{ track.title }}</a>{% unless forloop.last %} · {% endunless %}
    {% endfor %}
  {% else %}
    {% for key in track_keys %}
    <a href="#{{ key }}">{{ key | capitalize }}</a>{% unless forloop.last %} · {% endunless %}
    {% endfor %}
  {% endif %}
</p>

{% comment %}
  Normalise to a single loop variable so the listing below is written once.
  `site.tracks` entries carry {key, title}; derived keys carry only the key.
{% endcomment %}
{% if site.tracks %}
  {% assign track_list = tracks %}
{% else %}
  {% assign track_list = track_keys %}
{% endif %}

{% for track in track_list %}
  {% if site.tracks %}
    {% assign track_key = track.key %}
    {% assign track_title = track.title %}
    {% assign track_blurb = track.description %}
  {% else %}
    {% assign track_key = track %}
    {% assign track_title = track | capitalize %}
    {% assign track_blurb = nil %}
  {% endif %}

  {% assign track_entries = site.data.proceedings | where: "track", track_key | sort: "title" %}

  {% unless track_entries == empty %}
  <hr>
  <h2 id="{{ track_key }}">{{ track_title }} <small class="text-body-secondary">({{ track_entries.size }})</small></h2>

  {% if track_blurb %}
  {{ track_blurb | markdownify }}
  {% endif %}

  <ul>
    {% for entry in track_entries %}
    {% capture proceeding_entry_url %}{{ entry.id | datapage_url: "proceedings" | relative_url }}{% endcapture %}
    <li class="mb-2">
      <a href="{{ proceeding_entry_url }}"><strong>{{ entry.title }}</strong></a>
      {% if entry.format %}<span class="text-body-secondary">({{ entry.format }})</span>{% endif %}<br>
      {{ entry.authors }}
      {% if entry.session_name %}<br>
      <small class="text-body-secondary">{{ entry.session_name }}</small>
      {% endif %}
    </li>
    {% endfor %}
  </ul>
  {% endunless %}
{% endfor %}
