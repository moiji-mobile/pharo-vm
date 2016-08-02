#!/bin/bash

git checkout .
git clean -dxf .
make -f Makefile.debian

echo "deb http://download.opensuse.org/repositories/openSUSE:/Tools/xUbuntu_12.04/ ./" | sudo tee /etc/apt/sources.list.d/obs.list
wget -q -O/dev/stdout http://download.opensuse.org/repositories/openSUSE:/Tools/xUbuntu_12.04/Release.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install osc

cat <<- EOF > ~/.oscrc
[general]
apiurl = https://api.opensuse.org

[https://api.opensuse.org]
user = ${OBS_USER}
pass = ${OBS_PASS}
EOF

OBS_HOME="home:zecke23"
osc co ${OBS_HOME}/pharo5
osc co ${OBS_HOME}/pharo5-sources

pushd .
# rm files if directory is not empty
cd ${OBS_HOME}/pharo5
osc rm * || true
cd ../pharo5-sources
osc rm * || true
popd

# copy our new files and send them to obs
cp packaging/pharo5-sources-files_* ${OBS_HOME}/pharo5-sources
cp packaging/pharo5-vm-core_* ${OBS_HOME}/pharo5
cd ${OBS_HOME}/pharo5
osc add *.dsc *.tar.gz
osc ci -v -m "new build ${TRAVIS_COMMIT_RANGE}"
cd ../pharo5-sources
osc add *.dsc *.tar.gz
osc ci -v -m "new build ${TRAVIS_COMMIT_RANGE}"
