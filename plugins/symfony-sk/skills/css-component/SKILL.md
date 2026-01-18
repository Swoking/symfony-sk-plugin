---
name: symfony-sk:css-component
description: Create CSS/SCSS styles for components. Use for visual styling.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# CSS Component Skill

## Mission

Create CSS/SCSS styles for UI components.

---

## Location

`front/public/site/css/<feature>/<name>.css` (or `.scss`)

---

## Template - CSS

```css
/* Feature Component Styles */

.feature-component {
    /* Layout */
    display: flex;
    flex-direction: column;
    gap: 1rem;

    /* Spacing */
    padding: 1.5rem;
    margin-bottom: 1rem;

    /* Visual */
    background-color: var(--bg-color, #fff);
    border-radius: 0.5rem;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.feature-component__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.feature-component__title {
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--text-color, #333);
}

.feature-component__body {
    flex: 1;
}

.feature-component__footer {
    display: flex;
    justify-content: flex-end;
    gap: 0.5rem;
}

/* States */
.feature-component--loading {
    opacity: 0.6;
    pointer-events: none;
}

.feature-component--error {
    border-color: var(--error-color, #dc3545);
}
```

---

## Template - SCSS

```scss
// Feature Component Styles

$component-padding: 1.5rem;
$component-radius: 0.5rem;

.feature-component {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    padding: $component-padding;
    background-color: var(--bg-color, #fff);
    border-radius: $component-radius;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);

    &__header {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    &__title {
        font-size: 1.25rem;
        font-weight: 600;
    }

    &__body {
        flex: 1;
    }

    &__footer {
        display: flex;
        justify-content: flex-end;
        gap: 0.5rem;
    }

    // States
    &--loading {
        opacity: 0.6;
        pointer-events: none;
    }

    &--error {
        border-color: var(--error-color, #dc3545);
    }
}
```

---

## BEM Convention

- **Block**: `.feature-component`
- **Element**: `.feature-component__header`
- **Modifier**: `.feature-component--loading`

---

## CSS Variables

Use CSS variables for theming:

```css
.feature-component {
    --bg-color: #fff;
    --text-color: #333;
    --accent-color: #007bff;
}

[data-theme="dark"] .feature-component {
    --bg-color: #1a1a1a;
    --text-color: #f0f0f0;
}
```

---

## Checklist

- [ ] BEM naming convention
- [ ] CSS variables for theming
- [ ] States (loading, error, active)
- [ ] Responsive if needed
