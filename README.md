# jazzsequence/satis-server

[![Satis Build](https://github.com/jazzsequence/satis-server/actions/workflows/satis-build.yml/badge.svg)](https://github.com/jazzsequence/satis-server/actions/workflows/satis-build.yml)
[![Deploy to Pantheon](https://github.com/jazzsequence/satis-server/actions/workflows/push-to-pantheon.yml/badge.svg)](https://github.com/jazzsequence/satis-server/actions/workflows/push-to-pantheon.yml)
[![phpunit](https://github.com/jazzsequence/satis-server/actions/workflows/ci.yaml/badge.svg)](https://github.com/jazzsequence/satis-server/actions/workflows/ci.yaml)

A simple static Composer repository generator powered by [Satis](https://github.com/composer/satis).

The production implementation of this repository is hosted at [https://packages.jazzsequence.com](https://packages.jazzsequence.com).

To use the jazzsequence Satis server as a composer repository, add the following to your `composer.json`:

```json
{
    "repositories": [
        {
            "type": "composer",
            "url": "https://packages.jazzsequence.com"
        }
    ]
}
```

## What is Satis?

Satis is a tool that allows PHP developers to create a private package repository for their projects' dependencies. It provides
increased control over package distribution, improved security, and faster package installations, by creating a static Composer
registry that can be hosted anywhere (even via Docker, locally).

## Building Satis

The Satis repository is built daily as well as ad-hoc whenever a `composer install` or `composer update` is run. To manually build the Satis repository, run:

```bash
composer build-satis
```

Alternately, you can use the workflow dispatch feature in GitHub Actions to trigger a Satis build manually.
