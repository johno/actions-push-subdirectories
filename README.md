# Push Subdirectories

GitHub Action to push subdirectories to separate repositories.

### Why?

When building Gatsby Themes with a monorepo it's common to need to
be able to develop your corresponding starters in the same repo as
well. This allows you to automatically push your starters to their
own repo so they can be used with `gatsby new`.

## Usage

```tf
workflow "Update starters" {
  on = "push"
  resolves = ["johno/actions-push-subdirectories"]
  args = "examples"
}
```

## Related

This code is adapted and modified from [Gatsby core](https://github.com/gatsbyjs/gatsby/blob/8933ca9b3bf2c9b4fd580dd437d8695c3be705b7/scripts/clone-and-validate.sh).
