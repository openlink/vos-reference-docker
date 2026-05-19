# NEWS.md

## May 19 2026, v1.3:
  * Security Hardening
    - Hardened entrypoint script with strict bash mode (`set -Eeuo pipefail`)
    - Hardened execution of `initdb.d` shell scripts and Virtuoso start
      command using `gosu`
    - Hardened execution of scripts from `initdb.d`
    - Hardened generation of self-signed certificate
    - Hardened initial password generation and instance configuration
    - Hardened ownership and permissions under `/opt/virtuoso-opensource`
    - Fixed default umask for file permissions to `0077`

  * Bug Fixes
    - Fixed use of `PATH` to locate binaries
    - Fixed spelling

  * Maintenance
    - Updated runtime packages
    - Reduced size of Docker image
    - Fixed Docker build warnings and minor whitespace changes


## May 11 2026, v1.2:
  * Bug Fixes
    - Fixed use of `SSL_KEY_FILE` and `SSL_CRT_FILE`
    - Fixed issue reading Virtuoso PID from `virtuoso.lck` file
    - Fixed running the engine as the virtuoso user
    - Fixed permissions of `/settings/dba_password` and `/settings/dav_password`
    - Fixed issue looping over hosting directory when no plugins are present
    - Fixed missing error messages
    - Fixed issue when an equal character appears in a value
    - Fixed inconsistent use of `apt` commands
    - Fixed issue with symlinked entrypoint script on Kubernetes

  * Improvements
    - Added support for generating a self-signed certificate on new install
    - Updated Virtuoso account to use UID 1001
    - Replaced post-copy `chown -R` with `COPY --chown` to avoid duplicate layers

  * Maintenance
    - Updated documentation and README
    - Updated Copyright
    - Updated git tag to latest stable release
    - Added missing requirements for running the test suite


## Jan 1 2025, v1.1:

 * Improvements
    - Upgraded Docker image to use Ubuntu Noble Numbat (24.04) LTS
    - Added `MAKE_FLAGS` environment variable for faster parallel builds

 * Maintenance
    - Updated documentation
    - Updated Copyright
    - Updated git tag to latest stable release


## Dec 4 2023, v1.0:

  * Initial release
