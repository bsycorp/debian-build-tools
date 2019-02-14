# debian-build-tools
Minideb based docker image with tools for build / deploy jobs

[![Build Status](https://travis-ci.org/bsycorp/debian-build-tools.svg?branch=master)](https://travis-ci.org/bsycorp/debian-build-tools)

Images: https://hub.docker.com/r/bsycorp/debian-build-tools/tags/


# Troubleshooting

`aws ecr get-login` will fail with an error:

```
Error saving credentials: error storing credentials - err: exit status 1, out: `not implemented`
```

This is expected because aws credential helper doesn't support the full set of methods, you don't / shouldn't use `ecr get-login` any more though as it happens automatically.