---
layout: page  
title: Program
permalink: /program/
---

{% include all-sessions.html %}
{% assign sorted_sessions = all_sessions %}

{: .info-box}
The programme is also available [grouped by day and session]({% link program-by-session.md %}) and [as a flat list by track]({% link program-by-track.md %}).

<script>
  var calendarEvents = (function () {
    var sessions = {{ sorted_sessions | jsonify }};
    // Colour per session type, from `session_colours:` in _config.yml. The
    // `|| {}` matters: with no such key Liquid emits `null`, and indexing that
    // would throw here and leave the calendar with no events at all.
    var typeColours = {{ site.session_colours | jsonify }} || {};
    var fallback = getComputedStyle(document.documentElement)
      .getPropertyValue('--theme-link').trim() || '#b85e00';
    return sessions.map(function (session) {
      var colour = typeColours[session.type] || fallback;
      return Object.assign({}, session, {
        url: '{{ site.baseurl }}/sessions/' + session.id + '.html',
        backgroundColor: colour,
        borderColor: colour
      });
    });
  })();
</script>

{% include calendar-timezone-picker.html
   default_timezone="Australia/Sydney"
   default_timezone_label="Sydney (Default)" %}

{% if site.session_colours %}
<p class="session-key-list">
  {% for pair in site.session_colours %}
  <span class="session-key">
    <span class="session-key-swatch" style="background: {{ pair[1] }};"></span>{{ pair[0] | capitalize }}
  </span>
  {% endfor %}
</p>
{% endif %}

<h2>Sessions</h2>


<div class="row row-cols-1 row-cols-md-2 g-4">
  {% for session in sorted_sessions %}
    {% include session-card.html session=session %}
  {% endfor %}
</div>
