# Push Subdirectories

GitHub Action to push subdirectories to separate repositories.

### Why?

When building Gatsby Themes with a monorepo it's common to need to
be able to develop your corresponding starters in the same repo as
well. This allows you to automatically push your starters to their
own repo so they can be used with `gatsby new`.

## Usage

```yml
name: Publish Starters
on: push
jobs:
  master:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: publish:starters
        uses: johno/actions-push-subdirectories@master
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          args: examples johno
```

The `GITHUB_TOKEN` will automatically be defined, the `API_TOKEN_GITHUB` needs to be set in the `Secrets` section of your repository options. You can retrieve the `API_TOKEN_GITHUB` [here](https://github.com/settings/tokens) (set the `repo` permission).

The action accepts four arguments - the first two are mandatory, the third and fourth are optional.

1. Name of the folder that contains your examples. Even if you only have one example currently it also should be placed inside its own folder (e.g. `examples/foo-bar`) as the script will read all folders inside the examples.
2. GitHub username
3. Repository name of the respective example. By default the `name` key from the example's `package.json` is used, e.g. the `name` of your example is `gatsby-starter-foobar`, then the script will try to push to `github.com/USERNAME/gatsby-starter-foobar`.
4. The branch name that the changes should be pushed to. Defaults to `main`. 

### Custom starter names

You could define the key `starter-name` in your example's `package.json`, like:

```json
{
  "starter-name": "gatsby-starter-custom-foobar",
}
```

Use the action with the third argument now:

```yml
args: examples johno starter-name
```

Using the action to push to `master` branch:

```yml
args: examples johno starter-name master
```

## Related

This code is adapted and modified from [Gatsby core](https://github.com/gatsbyjs/gatsby/blob/8933ca9b3bf2c9b4fd580dd437d8695c3be705b7/scripts/clone-and-validate.sh).
