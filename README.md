# academic-org-theme

This is a Jekyll Theme for creating website for academic conferences, groups, and organisations. Having an advanced blog layout page, a complicated landing page, or providing lots of "profile"-style social media links is less important than providing clear and consistent pages.

This theme started out from a basic theme I developed for [my homepage](https://charlesmartin.au), and then for the [NIME community](https://nime.org).

## Installation

Add this line to your Jekyll site's `Gemfile`:

```ruby
gem "academic-org-theme"
```

And add this line to your Jekyll site's `_config.yml`:

```yaml
theme: academic-org-theme
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install academic-org-theme

## Usage

The theme ships with a small set of layouts, a navigation-driven top bar, and a data-pipeline that generates one page per row in `_data/proceedings.csv` and `_data/sessions.yml`. Most consuming sites can get started by setting a handful of config keys and adding Markdown pages that use `layout: page`.

### Required config

A minimal `_config.yml` for a theme consumer looks like this:

```yaml
title: My Conference 2026
tagline: A short subtitle shown under the site title.
description: >-
  Longer description used by jekyll-seo-tag for meta tags and feeds.
url: "https://example.org"
baseurl: ""

logo: /assets/logo.svg      # shown in the top-left of the nav
favicon: /assets/logo.svg
footer_copyright: My Conference

plugins:
  - jekyll-datapage-generator
  - jekyll-seo-tag
  - jekyll-redirect-from

navigation_header:
  - title: Home
    url: /
  - title: Call
    url: /call/
  - title: Program
    children:                 # a `children:` list makes this a dropdown
      - title: Calendar View
        url: /program/
      - title: By Session
        url: /program-by-session/
      - title: By Track
        url: /program-by-track/
  - title: Committee
    url: /committee/
```

Adding a page does **not** add it to the nav — update `navigation_header` too.

#### Dropdown menus

Give a nav entry a `children:` list to turn it into a Bootstrap dropdown. The
parent's own `url:` is optional — omit it for a menu label that isn't itself a
page. A parent is marked active when it or any of its children is the current
page.

Dropdowns need Bootstrap's JS bundle, which `_includes/scripts.html` already
loads. If you have overridden that include in your site, keep the script tag.

### Local development config

`_config.dev.yml` holds `url` / `baseurl` overrides for local work, so the
committed `_config.yml` can always carry the production values:

```
bundle exec jekyll serve --config _config.yml,_config.dev.yml
```

Later `--config` files win, so a staging deploy only needs to override those two
keys rather than fork the whole config.

### Layouts

| Layout | When to use |
| --- | --- |
| `page` | Standard content page with optional feature image. Wraps `default`. |
| `post` | Blog-style post with title/date. Wraps `default`. |
| `default` | Raw outer shell (nav + footer + scripts). Use when you need full control of the page body. |
| `proceeding_entry` | Auto-applied to each row of `_data/proceedings.csv` by the data-page generator. |
| `session_entry` | Auto-applied to each entry of every session source (`_data/sessions.yml` and friends) by the data-page generator. |

Example page front matter:

```yaml
---
title: Call for Papers
layout: page
feature_image: assets/hero.jpg
# Or, for a dark-mode aware hero:
# feature_image_light: assets/hero-light.jpg
# feature_image_dark: assets/hero-dark.jpg
---
```

### Data-driven pages: proceedings and sessions

The theme's headline feature is automatic generation of one page per paper and one page per session, with cross-links between them. This is driven by `jekyll-datapage-generator` and configured under `page_gen:` in `_config.yml` (see the demo config in this repo for the canonical setup).

- **`_data/proceedings.csv`** → `/proceedings/<id>.html`. Columns include `id`, `title`, `authors`, `abstract`, `track`, `session_code`, `session_name`, `session_position`, `demo_session_code`, `demo_session_name`, `demo_session_position`, `paper_url`, `video_url`, `slides_url`, `image_url`, `type`, `format`, `duration`, `presence`, `speaker`, `location`.
- **`_data/sessions.yml`** → `/sessions/<id>.html`. Keys include `id`, `title`, `subtitle`, `chair`, `date`, `start`, `end`, `location`, `type`, `allDay`.

A paper is linked to a session by matching `session_code` against a session's `id`. `session_code` may be a comma-separated list, so a single paper/artwork can appear in multiple sessions. Within a session, entries are ordered by `session_position`.

`session_name` is an optional parallel list of human-readable session names. Where present it is used as the link text on the entry page instead of the raw code, so a reader sees "Papers 2: Posters & Demos" rather than `papers-2`.

`track` groups entries for the by-track listing (see below). Use whatever track names your calls use — `papers`, `music`, `workshops`, and so on.

#### Cross-listing an entry into a second session

`demo_session_code` / `demo_session_name` / `demo_session_position` schedule an
entry into a *second* session in addition to its main one — the usual case being
a paper that also gets a demo slot. The demo session's page lists these
separately under "Demonstrations", with a pointer back to where the work is
mainly presented, and the entry page shows both sessions.

This is deliberately a separate set of columns rather than another comma-separated
`session_code`: the two appearances mean different things, need different
ordering, and should be labelled differently for readers.

#### Multiple session sources

Larger programmes have events that run *alongside* the schedule rather than in a
slot within it — standing installations, exhibits, anything always-on. List
extra data files under `session_sources:`:

```yaml
session_sources:
  - data: sessions
    title: Sessions
  - data: installations
    title: Installations
```

Each source also needs its own `page_gen:` block. Point them at the same
`dir: sessions` so `datapage_url: "sessions"` resolves links to all of them
uniformly.

Templates read the merged, start-sorted set through an include:

```liquid
{% include all-sessions.html %}
{% for session in all_sessions %} ... {% endfor %}
```

Multi-day entries should use FullCalendar's recurrence keys (`startRecur`,
`endRecur`, `startTime`, `endTime`, `daysOfWeek`) so they repeat across days on
the calendar instead of rendering as one enormous block.

#### Helper includes

| Include | Purpose |
| --- | --- |
| `all-sessions.html` | Sets `all_sessions` — every session source merged and sorted by `start`. |
| `session-entries.html` | Sets `matched_entries` — the proceedings entries in a given session. Takes `field`, `session_id`, `sort_by`. |
| `session-card.html` | Renders one session as a Bootstrap card. Takes `session`. |

`session-entries.html` matches whole comma-separated codes rather than
substrings, so session `papers-1` does not swallow the entries of `papers-10`.

To link between generated pages from a template, use the `datapage_url` filter:

```liquid
<a href="{{ entry.id | datapage_url: 'sessions' | relative_url }}">{{ entry.title }}</a>
```

The string argument (`"sessions"` or `"proceedings"`) must match the `data:` key under `page_gen:`.

### Program pages

The repo ships three views of the same data. Copy whichever you want into your
consuming site as a starting point; they are ordinary pages, not layouts.

| Page | View |
| --- | --- |
| `program.md` | FullCalendar timetable plus a card grid, with a timezone picker. Opens on the conference, not on today. |
| `program-by-session.md` | Day-by-day accordion, each day split into always-on / morning / afternoon. |
| `program-by-track.md` | Flat list of every contribution grouped by `track` — the page attendees use to find one specific work. |

Both new pages derive their structure from the data, so they need no editing when
the schedule changes:

- Days on `program-by-session.md` come from the session `start` values. The
  morning/afternoon split defaults to 12:30 and is set with
  `programme_midday: "13:00"` in `_config.yml`. Entries with `type: break` are
  listed inline rather than as cards.
- Tracks on `program-by-track.md` are derived from the `track` column and sorted
  alphabetically. To control order and display names, set `tracks:` in
  `_config.yml`:

  ```yaml
  tracks:
    - key: papers
      title: Papers
      description: Optional markdown blurb shown under the heading.
    - key: music
      title: Music & Performance
  ```

### Accessibility page

`accessibility.md` is a skeleton FAQ covering the questions attendees need
answered before they can decide whether they can attend — interpretation and
captioning, step-free access, assistance animals, sensory warnings, quiet
spaces, dietary needs, financial support. Every answer is a placeholder.

Publish it early even where the answer is still "we are working on this". Do not
delete a question because the answer is unknown or inconvenient: "we cannot
provide this" is a useful answer and silence is not.

### Committee page

`_data/committee.yml` is a flat list of `{name, aff, im, role, url}` entries. `committee.md` iterates it to render a cards grid.

### Feature images and dark mode

`feature_image` renders a single hero image. For a dark-mode-aware hero, set `feature_image_light` and `feature_image_dark` instead — the theme script in `_includes/nav.html` swaps any element carrying both `data-light-img` and `data-dark-img` when the theme changes, and `_includes/head.html` resolves the theme before first paint so there is no flash of the wrong mode.

### SEO

The theme includes [`jekyll-seo-tag`](https://github.com/jekyll/jekyll-seo-tag/) for metadata in page headers. See its [usage page](https://github.com/jekyll/jekyll-seo-tag/blob/master/docs/usage.md) for the front-matter keys it consumes (`title`, `description`, `image`, `author`, and so on).

### Colour scheme

Four base colours in `_config.yml` drive every colour on the site — links,
callout boxes, table rules, borders, Bootstrap's own components, and the whole
dark scheme:

```yaml
colours:
  primary:   "#b85e00"  # links, primary actions, keynote events
  highlight: "#ebd999"  # dark-mode text, warning surfaces
  secondary: "#58771e"  # info boxes, paper sessions
  ink:       "#1b3644"  # body text (light), page background (dark)
```

Defaults are Wada Sanzo plate 243. Change these four and everything follows.

`assets/styles.scss` derives light and dark values from them and publishes both
sets as CSS custom properties (`--theme-bg`, `--theme-ink`, `--theme-link`,
`--theme-info-bg`, and so on), then hands the palette to Bootstrap by
overriding `--bs-*`. Component rules only ever reference the custom properties,
never a literal colour, so nothing can strand a hardcoded value in one mode.

#### Neutral text, coloured accents

Body copy, headings, muted text and borders are **neutral greys**, not palette
hues. The four base colours are reserved for things that carry meaning — links,
callout boxes, session types, inline code. A page whose body text is tinted has
spent its accent budget on prose, and nothing is left to mark what matters.

The greys are not true `#808080`: they are `ink` with 80% of its saturation
scaled out, so they stay faintly cool and sit in the same family as the palette
without reading as coloured. In dark mode the page background and raised
surfaces still carry the `ink` tint — the background is allowed to be
brand-coloured — but the text on top of them is neutral.

Adjust the ramp through the `neutral()` function rather than by hand; it takes
an HSL lightness, so `neutral(20%)` and `neutral(88%)` are the light and dark
body text.

Surfaces come in three steps — page, raised, and callout — and in dark mode they
sit close together (14% / 18% / 20%) so the page reads as one continuous field
rather than a stack of panels. The page, the main container and the content area
all share the page value, so there is no visible seam between them.

Keep those steps close. Muted text and borders are checked against the *lightest*
surface they can land on, not the page, and spreading the surfaces further apart
is what breaks those two first.

**When overriding a Bootstrap colour variable, set its `--bs-*-rgb` companion
too.** The utility classes (`.bg-body`, `.bg-body-tertiary`, `.text-body` …)
read the comma-separated `-rgb` form, not the colour variable. Setting only
`--bs-body-bg` leaves `.bg-body` painting Bootstrap's stock charcoal — which for
a while is exactly what the main container did, on a differently-coloured page.
Use the `rgb-channels()` helper.

#### Bootstrap's component variables are stubborn

Setting `--bs-primary` and `--bs-link-color` at `:root` does **not** restyle
Bootstrap's components. Each one declares its own scoped layer, and many entries
in that layer are literal colours rather than references — `.dropdown-menu` ships
`--bs-dropdown-link-active-bg: #0d6efd`, so the selected menu item stays
Bootstrap blue no matter what the palette says.

Every component the theme renders therefore gets its own override block in
`assets/styles.scss`: `.navbar`, `.dropdown-menu`, `.btn-outline-secondary`, plus
the globals other components reach for (`--bs-border-color-translucent` for card
and dropdown borders, `--bs-focus-ring-color` for every focusable element,
`--bs-secondary`, `--bs-tertiary-color`, `--bs-highlight-bg`).

**If you add a Bootstrap component, check its variables.** Grep
`assets/imports/bootstrap/bootstrap.min.css` for `--bs-<component>-` and look for
literal hex values; anything that carries one needs an entry.

Two specificity notes, both of which have bitten this file:

- Theme values are published from `:root` and `:root[data-bs-theme="dark"]`, so
  the dark block outranks Bootstrap's own `[data-bs-theme="dark"]` regardless of
  stylesheet order. A bare `[data-bs-theme="dark"]` selector ties on specificity
  and then depends on load order.
- Bootstrap's `.navbar-dark, .navbar[data-bs-theme=dark]` would outrank a plain
  `.navbar` override, but only matches when the attribute sits on the navbar
  element itself. This theme sets it on `<html>`, so it never matches. Adding
  `navbar-dark` to the markup would resurrect the stock colours.

#### Highlighted states

`--theme-accent-bg` / `--theme-accent-fg` are the filled "this one is selected"
pair, used by the active dropdown item and by button hover. The foreground has to
flip between modes: the light accent is a dark brown that carries white, while
the dark accent is a light amber where white manages only 2.52:1, so it takes the
page charcoal instead.

Inline code uses the secondary hue on a faint chip. Bootstrap's default is
`#d63384`, a pink from no palette here that manages only 4.50:1 on white. The
dark variant is lightened toward white rather than toward `highlight`, which
would pull it khaki.

The dark values are **not** the light values lightened. Light mode mixes each
accent toward white; dark mode mixes it into the page background instead. Doing
the former in both — which this theme used to do — leaves callout boxes with a
pale fill behind light dark-mode body text, at about 1.1:1.

`ink` does double duty as light-mode body text and the dark-mode page
background, so it needs to stay dark. `highlight` carries dark-mode text and
needs to stay light.

#### Contrast

Every derived pair is checked against WCAG AA — 4.5:1 for text, 3:1 for borders
and large text — in both modes. The measured ratio is recorded in a comment
beside each derived value in `assets/styles.scss`, against the surface that
colour actually sits on.

If you change the base colours, re-check. The tightest relationships are the
link colour on raised surfaces (cards and callouts, not the page background)
and the callout accent against its own fill; those are the first to fail.

The link hover reverses to white on a gradient that stays inside the primary
hue, ramping only in lightness. An earlier version ran from primary to
secondary; across an inline link a few characters wide that reads as lurid,
because the two are close in luminance and the sweep is almost pure hue
rotation. Keeping one hue and varying lightness gives the same effect without
the clash. White clears AA at every point along the ramp, and the light end is
the binding constraint — the base primary manages only 4.53:1 by itself, so
both ends sit slightly darkened toward `ink`.

#### Calendar date range

The calendar works out the conference span from the event data: it opens on the
first day with activity, sizes the grid to exactly the number of days the
programme covers, and fences navigation to that range with `validRange`. A
conference website is read for years afterwards, so anchoring the view to
"today" would show an empty grid to almost everyone who visits.

Because the whole conference is already on screen, the header's `prev` / `next` /
`today` buttons are dropped — there is nowhere to page to. They come back only if
the span exceeded `max_days` (default 10) and had to be truncated, which in
practice means a typo in a date; that case also logs a console warning naming the
offending range rather than silently rendering a months-long grid.

Days are compared as `YYYY-MM-DD` strings sliced off the front of each ISO
timestamp, so an event belongs to the day its own timestamp names regardless of
the viewer's timezone or the picker's current selection. An event ending at
exactly midnight closes the previous day rather than opening a new empty one.

Day arithmetic on those strings runs in **UTC**, via `Date.UTC`. This matters:
`new Date('2025-10-17T12:00:00')` parses as *local* time, so reading it back out
with `toISOString()` crosses a date boundary wherever the viewer's offset exceeds
±12h — Auckland at +13, Chatham at +13:45, Kiritimati at +14, and UTC−12 the
other way. That shifted the computed range by a day for those viewers and clipped
the last day of the conference. Picking a midday anchor dodges DST but not this;
staying in UTC avoids both, since UTC has no DST either.

Pass `duration_days` to the include to override the derived span.

#### Session colours

`session_colours:` in `_config.yml` maps each session `type:` to a calendar
event colour. FullCalendar puts a white label on these, so each one is verified
to carry white text at AA. Add an entry when you add a session type — anything
unlisted falls back to the palette's link colour. `/program/` renders a legend
from the same map, so the key can't drift from the calendar.

Eight colours derived from four bases means some pairs sit close together in
hue. They are spread across lightness as well, which helps, but if you need
them more distinct that is the place to adjust.

### Styling

Styles live in `assets/styles.scss` on top of Bootstrap 5.3.0. To override theme styles in a consuming site, create your own `assets/styles.scss` with the same path — Jekyll will prefer the site's copy over the one from the gem. `_sass/` is available for partials if you want to split things up.

Content tables reflow to stacked cards below 768px, so a wide programme or fee
table stays readable on a phone without side-scrolling. Colours come from
Bootstrap custom properties, so both the tables and the programme accordions
follow the light/dark theme.

## Vendored dependencies

Front-end dependencies are **self-hosted** under `assets/imports/` rather than
loaded from a CDN. A conference site needs to still render years after the event,
long after any given CDN has reorganised its URLs — and self-hosting also means
no third-party requests from visitors' browsers, and builds that work offline.

| Dependency | Version | Path |
| --- | --- | --- |
| Bootstrap CSS + JS bundle | 5.3.0 | `assets/imports/bootstrap/` |
| Font Awesome | 6.7.2 | `assets/imports/fontawesome/` |
| Academicons | 1.9.4 | `assets/imports/academicons/` |
| FullCalendar (+ moment-timezone plugin) | 6.1.17 | `assets/imports/fullcalendar/` |
| Moment / Moment Timezone | 2.29.4 / 0.5.40 | `assets/imports/moment/` |
| lite-youtube | 1.8.1 | `assets/imports/lite-youtube/` |

To update one, replace the files in place and bump the version in this table. The
icon-font packages need their font files as well as their CSS — Font Awesome's
CSS resolves `../webfonts/` and Academicons' resolves `../fonts/`, both relative
to the stylesheet, so keep the `css/` + `webfonts/` (or `fonts/`) layout intact.
Dropping in the CSS alone silently breaks every icon.

Only Font Awesome's `.woff2` files are vendored, not the `.ttf` fallbacks beside
them in the upstream package. Both formats sit in the same `src:` list, so a
browser takes the woff2 and never requests the ttf — the references to the
missing files are dead weight, not broken links. Add the `.ttf` files if you need
to support a browser without woff2 support.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smcclab/academic-org-theme. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## Development

To set up your environment to develop this theme, run `bundle install`.

Your theme is setup just like a normal Jekyll site! To test your theme, run `bundle exec jekyll serve` and open your browser at `http://localhost:4000`. This starts a Jekyll server using your theme. Add pages, documents, data, etc. like normal to test your theme's contents. As you make modifications to your theme and to your content, your site will regenerate and you should see the changes in the browser after a refresh, just like normal.

When your theme is released, only the files in `_layouts`, `_includes`, `_sass` and `assets` tracked with Git will be bundled.
To add a custom directory to your theme-gem, please edit the regexp in `academic-org-theme.gemspec` accordingly.

## License

The theme is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
