#!/bin/bash
# invoke_maven.sh

##
## Wrapper script for invoking Maven with per-branch local repository.
##
## To set up, ensure the directory containing this file is in the PATH, and
## that BUILD_ROOT points to a directory where the local repository will be
## stored.
##

if [ -z "${BUILD_ROOT}" ]; then
    echo "ERROR: BUILD_ROOT not set"
    exit 1
fi

_basedir="$(cd $(dirname ${0}) && /bin/pwd)"

defaults="${_basedir}/defaults.sh"

## Ensure defaults.sh exists, then source it in
if [ ! -e "${defaults}" ]; then
    echo "ERROR: cannot find $defaults"
    exit 1
fi

. "${defaults}"

## defaults.sh needs to have DEFAULT_JAVA_HOME and DEFAULT_M2_HOME set.
if [ -z "$DEFAULT_JAVA_HOME" ]; then
    echo "ERROR: DEFAULT_JAVA_HOME not set"
    exit 1
fi

if [ -z "$DEFAULT_M2_HOME" ]; then
    echo "ERROR: DEFAULT_M2_HOME not set"
    exit 1
fi

## prepare JAVA_HOME and M2_HOME for export
JAVA_HOME="$DEFAULT_JAVA_HOME"
M2_HOME="$DEFAULT_M2_HOME"
MAX_HEAP="${DEFAULT_MAX_HEAP}"

## source in the per-buildroot config, which can override JAVA_HOME and
## M2_HOME
if [ -e "${BUILD_ROOT}/config.sh" ]; then
    # echo "sourcing ${BUILD_ROOT}/config.sh"
    . "${BUILD_ROOT}/config.sh"
fi

## spew warnings if these are overridden; that should only be done for
## short-term testing.
if [ "${JAVA_HOME}" != "${DEFAULT_JAVA_HOME}" ]; then
    echo "WARNING: JAVA_HOME overridden; now ${JAVA_HOME}"
fi

if [ "${M2_HOME}" != "${DEFAULT_M2_HOME}" ]; then
    echo "WARNING: M2_HOME overridden; now ${M2_HOME}"
fi

if [ "${MAX_HEAP}" != "${DEFAULT_MAX_HEAP}" ]; then
    echo "WARNING: MAX_HEAP overridden; now ${MAX_HEAP}"
fi

## finalize environment
export JAVA_HOME M2_HOME

## used in common_settings.xml for <localRepository />
export BUILD_ROOT_REPOSITORY="${BUILD_ROOT}/repository"

## ensure Maven loads common_settings.xml as the source of its settings, while
## still allowing the user to have their own settings.xml
# -Dorg.apache.maven.global-settings is deprecated as of 2.1.0; replace w/ "-gs"
# http://maven.40175.n5.nabble.com/settings-xml-precedence-td118292.html
export MAVEN_OPTS="${MAVEN_OPTS} -Xmx${MAX_HEAP} -XX:MaxPermSize=256m -Dfile.encoding=UTF-8 -Dorg.apache.maven.global-settings=${_basedir}/common_settings.xml"
export PATH="${M2_HOME}/bin:${JAVA_HOME}/bin:${PATH}"

## fire off maven
exec mvn -gs "${_basedir}/common_settings.xml" "$@"
