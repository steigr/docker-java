# Oracle JDK/JRE

- Based on [alpinelinux with Oracle JRE](http://hub.docker.com/r/anapsix/alpine-java)

## Usage

Create your docker image as usual but define the following variables:

```
ENV APPLICATION_USER my-application-user
```

Futhermore you may use the included shell scripts:

- `. /environment-hygiene` to clean up the environment just before starting your main application.
- `. /with-reaper` to run your entrypoint script within `tini`. Place that call really early in your entrypoint script.

- `. /tomcat-configurator` relies on `$CATALINA_HOME` and `$APPLICATION_USER` and overwrites the "$@" variable. You may then start tomcat like `exec -- JAVA_OPTS="$JAVA_OPTS" "$@"`
- `. /log4j-configurator` (TBD) configures Log4J and prepares `$JAVA_OPTS`
- `. /timezone-configurator` append environment variable `TIMEZONE` to `$JAVA_OPTS`

### Examples

#### entrypoint.sh

```
#!/usr/bin/env bash

. with-reaper

export CATALINA_HOME=/app
. tomcat-configurator
. log4j-configurator
set -- JAVA_OPTS="$JAVA_OPTS" "$@"
. environment-hygiene
echo /usr/bin/env - "$@"
exec /usr/bin/env - "$@"
```

#### Dockerfile

```
FROM steigr/java
ENV  APPLICATION_USER=app
ADD  my-app/ app/
RUN  addgroup -S $APPLICATION_USER \
 &&  adduser -h /app -G $APPLICATION_USER -g '' -S -D -H $APPLICATION_USER \
 &&  chown -R $APPLICATION_USER:$APPLICATION_USER /app
ADD  entrypoint.sh /bin/my-app
ENTRYPOINT ["my-app"]
```

## Additional Components
- tini as sub-process reaper
- su-exec to run under a particular user

## Environment cleanup tools

Most docker images do not clean up environment variables before starting the actual service. This may be a problem, if someone can read the environment of a process either via `printenv` or via `cat /proc/self/environ` as sensible data may be stored there.

There are 2 scripts to clean up the environment.

1. Clean up the environment
```shell
# clean up all environment variables, except $HOME, $USER and $PATH
# set preserve=() to keep further environment variables
preserve=(JAVA_HOME CATALINA_TMPDIR)
. /environment-hygiene
```

2. Start `tini` in a clean fashion
```shell
# this script checks if tini is running
# if not it saves the complete environment a file and exec's the current script with tini as sup-process reaper
# if tini is running it restores the environment from file and removes it
# thus PID 1 has a clean environment too.
. /with-reaper
```

## Docker Image

[![](https://images.microbadger.com/badges/image/steigr/java.svg)](http://microbadger.com/images/steigr/java "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/steigr/java.svg)](http://microbadger.com/images/steigr/java "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/steigr/java.svg)](http://microbadger.com/images/steigr/java "Get your own commit badge on microbadger.com")