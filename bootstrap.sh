# Run this in a path you don't care about, things may get deleted!
VERSION="0.9.12"
BUILD="betable2"

set -e -x
ORIGPWD="$(pwd)"
TMP="$(mktemp -d)"
cd $TMP
trap "rm -rf \"$TMP\"" EXIT INT QUIT TERM

git clone --depth 1 git@github.com:graphite-project/carbon.git
cd carbon
git checkout "tags/$VERSION"

# Apply patches
patch -p1 < "$ORIGPWD/patches/graphite-syslogger.patch"

python setup.py install --install-data $TMP/prepare/var/lib/graphite --install-lib $TMP/prepare/opt/graphite/lib --prefix $TMP/prepare/opt/graphite
cd ../prepare

rm -f "$ORIGPWD/carbon_${VERSION}-${BUILD}_amd64.deb"

fakeroot fpm -m "Nate Brown <nate@betable.com>" \
             -n "carbon" -v "$VERSION-$BUILD" \
             -p "$ORIGPWD/carbon_${VERSION}-${BUILD}_amd64.deb" \
             -s "dir" -t "deb" "."
