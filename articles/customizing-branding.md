# Customizing Branding

`typstR` exposes branding through YAML fields in `template.qmd`. The
intended workflow is to edit those fields in Quarto, not to patch the
shipped Typst template.

For the base install -\> scaffold -\> render workflow, start with
[`vignette("getting-started", package = "typstR")`](https://davidzenz.github.io/typstR/articles/getting-started.md).
This article assumes you already have a working paper scaffold and only
want to tune the YAML-facing branding controls.

## Start from the commented branding block

The working paper starter ships with these commented fields:

``` yaml
typstR:
  # logo: "logo.png"
  # accent-color: "#0A5DA6"
  # primary-font: "Linux Libertine"
  # footer: "Working Paper Series"
  # disclaimer-page: true
```

Uncomment the fields you need and keep the rest at their defaults.

## Add a logo and accent color

Use `logo` for an image path relative to the manuscript, and
`accent-color` for the main highlight color used by the format.

``` yaml
typstR:
  logo: "logo.png"
  accent-color: "#0A5DA6"
```

This is usually enough to align the title page with an institute or
working paper series.

## Change the primary font and footer

`primary-font` changes the main text family, while `footer` adds short
text to the page footer.

``` yaml
typstR:
  primary-font: "Linux Libertine"
  footer: "Working Paper Series"
```

Use a font that is available in the rendering environment. If you are
sharing a project, document any non-default font requirement alongside
the manuscript.

## Adjust margins and disclaimer behavior

You can also set custom margins and enable a disclaimer page directly in
YAML.

``` yaml
typstR:
  margins:
    x: 1.1in
    y: 1in
  disclaimer-page: true
```

`disclaimer-page` is useful when a series needs a standard notice ahead
of the main manuscript.

## Render only when Quarto is available

Branding changes take effect at render time, so the example call stays
non-evaluated in the vignette:

``` r

render_working_paper("my-paper/template.qmd")
```

If the output does not look right, inspect the YAML field names first.
The most common mistake is using a near miss such as `accent_color`
instead of `accent-color`.

For the end-to-end onboarding flow, return to
[`vignette("getting-started", package = "typstR")`](https://davidzenz.github.io/typstR/articles/getting-started.md).
