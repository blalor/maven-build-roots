This project contains a set of scripts and configuration files for setting up
siloed build environments ("build roots") for Maven projects.  Each build root
contains its own local repository.

The "invoke_maven.sh" script wraps the "mvn" script and configures
common_settings.xml in place of $M2_HOME/conf/settings.xml, and optionally
allows for per-build-root Java and Maven versions (via the JAVA_HOME and
M2_HOME environment variables).  JAVA_HOME and M2_HOME are *not* taken from
the standard shell environment, but are instead loaded with default values
from defaults.sh, and overridden with values from config.sh in each build
root.

To set up invoke_maven.sh for a particular build root, set the BUILD_ROOT
environment variable to point to the build root directory (usually a child of
this directory), and ensure that this directory is in the path.  For example:
    # export PATH=/path/to/this/directory:$PATH
    # export BUILD_ROOT=/path/to/build/root
    # cd /path/to/maven_project
    # invoke_maven.sh -PALL clean install

Suggested directory layout:
    build_roots              -- this directory
    |-- common_settings.xml  -- Maven settings.xml shared by all build roots
    |-- defaults.sh          -- default values for JAVA_HOME and M2_HOME
    |-- invoke_maven.sh      -- Maven wrapper script
    |
    `-- tpi_core             -- a build root
        |-- checkout         -- where source code gets checked out to
        |   `-- trunk
        |-- config.sh        -- per-build-root config (JAVA_HOME, M2_HOME)
        `-- repository       -- per-build-root local repository
