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
    var typeColours = {
      admin:         '#2e312d',
      keynote:       '#b69255',
      papers:        '#7e7a72',
      artworks:      '#565b68',
      workshops:     '#5f6e62',
      discussion:    '#97a7b6',
      installations: '#97a7b6',
      break:         '#8f95a5'
    };
    return sessions.map(function (session) {
      var colour = typeColours[session.type];
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

<h2>Sessions</h2>


<div class="row row-cols-1 row-cols-md-2 g-4">
  {% for session in sorted_sessions %}
    {% include session-card.html session=session %}
  {% endfor %}
</div>
