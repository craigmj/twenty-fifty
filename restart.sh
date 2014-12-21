#!/bin/bash
set -e

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
  RVMB="$HOME/.rvm/bin/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
  RVMB="/usr/local/rvm/bin/rvm"
else
 curl -sSL https://get.rvm.io | bash
 source "$HOME/.rvm/scripts/rvm"
 RVMB="$HOME/.rvm/bin/rvm"
fi
rvm use 2.1.5

pushd /opt/decc/twenty-fifty
rm -f Gemfile.lock
deccgem gemfile > Gemfile
bundle install
sudo stop decc2050 || true
sudo start decc2050
popd
