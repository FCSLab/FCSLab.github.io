---
layout: page
title: Program by Session
description: The full programme, grouped by day and session.
permalink: /program-by-session/
---

{% comment %}
  Day-by-day view of the programme. Days are derived from the session data, so
  this page needs no editing when the schedule changes — add sessions to any of
  the `session_sources` data files and they appear here.

  Within a day, sessions are bucketed by when they run:
    - always-on   : allDay entries, and multi-day entries using FullCalendar
                    recurrence keys (startRecur). Shown once at the top.
    - morning     : starts before `site.programme_midday` (default 12:30)
    - breaks      : type: break — listed inline rather than as cards
    - afternoon   : starts at or after `site.programme_midday`
{% endcomment %}

{% include all-sessions.html %}
{% assign midday = site.programme_midday | default: "12:30" %}

{% comment %}
  Collect the days the programme covers. A multi-day entry contributes both its
  first and last day, so a day that holds nothing but a standing installation
  still gets a heading. ISO dates sort lexicographically, so a plain sort puts
  them in chronological order.
{% endcomment %}
{% assign day_keys = "" | split: "" %}
{% for session in all_sessions %}
  {% assign day = session.start | slice: 0, 10 %}
  {% unless day_keys contains day %}
    {% assign day_keys = day_keys | push: day %}
  {% endunless %}
  {% assign last_day = session.endRecur | default: session.end | default: session.start | slice: 0, 10 %}
  {% unless day_keys contains last_day %}
    {% assign day_keys = day_keys | push: last_day %}
  {% endunless %}
{% endfor %}
{% assign day_keys = day_keys | sort %}

{% if day_keys.size > 1 %}
<p>Jump to:
  {% for day in day_keys %}
  <a href="#day-{{ day }}">{{ day | date: "%A %-d %B" }}</a>{% unless forloop.last %} · {% endunless %}
  {% endfor %}
</p>
{% endif %}

{% for day in day_keys %}
  {% comment %} Partition this day's sessions into the four buckets. {% endcomment %}
  {% assign always_on = "" | split: "" %}
  {% assign morning = "" | split: "" %}
  {% assign afternoon = "" | split: "" %}
  {% assign breaks = "" | split: "" %}

  {% for session in all_sessions %}
    {% assign session_day = session.start | slice: 0, 10 %}
    {% if session.allDay or session.startRecur %}
      {% comment %}
        Always-on entries span a date range, so they are listed on every day
        they run rather than only on the day they start.
      {% endcomment %}
      {% assign span_start = session.startRecur | default: session.start | slice: 0, 10 %}
      {% assign span_end = session.endRecur | default: session.end | default: session.start | slice: 0, 10 %}
      {% if day >= span_start and day <= span_end %}
        {% assign always_on = always_on | push: session %}
      {% endif %}
    {% elsif session_day == day %}
      {% assign session_time = session.start | slice: 11, 5 %}
      {% if session.type == "break" %}
        {% assign breaks = breaks | push: session %}
      {% elsif session_time < midday %}
        {% assign morning = morning | push: session %}
      {% else %}
        {% assign afternoon = afternoon | push: session %}
      {% endif %}
    {% endif %}
  {% endfor %}

  <details class="programme-day" id="day-{{ day }}" open>
    <summary>
      <h2>{{ day | date: "%A, %-d %B %Y" }}</h2>
    </summary>

    <div class="programme-day-content">
      {% unless always_on == empty %}
      <h3 class="mt-4">Running All Day</h3>
      <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-4">
        {% for session in always_on %}
          {% include session-card.html session=session %}
        {% endfor %}
      </div>
      {% endunless %}

      {% unless morning == empty %}
      <h3 class="mt-4">Morning</h3>
      <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-4">
        {% for session in morning %}
          {% include session-card.html session=session %}
        {% endfor %}
      </div>
      {% endunless %}

      {% unless breaks == empty %}
      <ul class="mt-4">
        {% for session in breaks %}
        <li>
          <strong>{{ session.title }}</strong>
          {{ session.start | date: "%l:%M %p" | strip }}–{{ session.end | date: "%l:%M %p" | strip }}
          {% if session.location %}· {{ session.location }}{% endif %}
        </li>
        {% endfor %}
      </ul>
      {% endunless %}

      {% unless afternoon == empty %}
      <h3 class="mt-4">Afternoon &amp; Evening</h3>
      <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-4">
        {% for session in afternoon %}
          {% include session-card.html session=session %}
        {% endfor %}
      </div>
      {% endunless %}
    </div>
  </details>
{% endfor %}
