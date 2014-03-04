#!/bin/bash

gem clean
cd ../decc_2050_model
gem build model.gemspec
gem install decc_2050_model-0.60.20140228pre.gem
cd ../twenty_fifty
bundle
rackup
