#!/bin/bash

gem clean
cd ../decc_2050_model
gem build model.gemspec
gem install decc_2050_model-0.71.20140319pre.gem
cd ../twenty-fifty
bundle install
rackup
