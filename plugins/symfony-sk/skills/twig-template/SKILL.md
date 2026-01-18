---
name: symfony-sk:twig-template
description: Create Twig templates for pages and partials. Use for HTML rendering.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Twig Template Skill

## Mission

Create Twig templates for pages and partials.

---

## Location

- Front: `front/templates/<feature>/<name>.html.twig`
- Back: `back/templates/<feature>/<name>.html.twig`

---

## Key Rules

### No Hardcoded Text

**CRITICAL: All text must use translations.**

```twig
{# WRONG #}
<h1>My Title</h1>

{# CORRECT #}
<h1>{{ 'feature_page_title' | cache }}</h1>
```

### Translation Filters

```twig
{# Basic translation (uses labelFO in front, labelBO in back) #}
{{ 'key' | cache }}

{# For JavaScript - makes keys available as window.trad.key #}
{% block jsImport %}
    {{ ['key1', 'key2'] | tradJS }}
{% endblock %}
```

---

## Template Structure

```twig
{% extends 'base.html.twig' %}

{% block title %}{{ 'feature_page_title' | cache }}{% endblock %}

{% block stylesheets %}
    {{ parent() }}
    <link rel="stylesheet" href="{{ asset('site/css/feature/page.css') }}">
{% endblock %}

{% block body %}
    <div class="feature-page">
        <h1>{{ 'feature_page_title' | cache }}</h1>

        {# Content here #}
    </div>
{% endblock %}

{% block jsImport %}
    {{ parent() }}
    {{ ['feature_confirm_btn', 'feature_cancel_btn'] | tradJS }}
    <script src="{{ asset('site/js/feature/page.js') }}"></script>
{% endblock %}
```

---

## Common Patterns

### Loop
```twig
{% for item in items %}
    <div>{{ item.title }}</div>
{% else %}
    <p>{{ 'feature_no_items' | cache }}</p>
{% endfor %}
```

### Conditional
```twig
{% if user.isAdmin %}
    <button>{{ 'feature_admin_btn' | cache }}</button>
{% endif %}
```

### Include partial
```twig
{% include 'components/modal.html.twig' with {
    'titleKey': 'feature_modal_title',
    'content': data
} %}
```

---

## Checklist

- [ ] All text uses `| cache` filter
- [ ] JS keys passed via `| tradJS`
- [ ] Extends appropriate base template
- [ ] Assets loaded in correct blocks
- [ ] Labels created via `/label` skill
