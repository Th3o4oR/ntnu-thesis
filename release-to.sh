#!/usr/bin/env bash
#
# Release a Typst package version to a local target directory.
# Only copies files listed in the git repository, excluding everything
#   listed in .releaseignore.

set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h] <target-package-dir>

Release the current Typst package into <target-package-dir>/<version>.

Arguments:
  target-package-dir   Path to the destination package folder

Options:
  -h, --help           Show this help message
EOF
}

# Handle help flags
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

# Validate arguments
if [ "$#" -ne 1 ]; then
    echo "ERROR: Missing target package directory." >&2
    echo "" >&2
    usage >&2
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: Target is not a directory: $TARGET_DIR" >&2
    exit 2
fi

if [ ! -f "./typst.toml" ]; then
    echo "ERROR: No typst.toml found in current directory." >&2
    exit 3
fi

# Extract version from typst.toml
VERSION="$(sed -n 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' typst.toml | head -n 1)"

if [ -z "$VERSION" ]; then
    echo "ERROR: Could not parse version from typst.toml." >&2
    exit 4
fi

DEST="$TARGET_DIR/$VERSION"

if [ -d "$DEST" ]; then
    echo "ERROR: Target directory already has version $VERSION." >&2
    exit 5
fi

# Stage and copy files into destination
mkdir -p "$DEST"

if [ -f ".releaseignore" ]; then
    git ls-files -z | grep -zvf ".releaseignore" | rsync -a --files-from=- --from0 ./ "$DEST"
else
    git ls-files -z | rsync -a --files-from=- --from0 ./ "$DEST"
fi

echo "Success! Released version $VERSION to $DEST"
