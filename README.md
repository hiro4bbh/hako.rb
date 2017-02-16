# hako.rb - a simple data manipulation library written in Ruby
![hako.rb logo](https://rawgit.com/hiro4bbh/hako.rb/master/icon_title.svg)

[![Build Status](https://travis-ci.org/hiro4bbh/hako.rb.svg?branch=master)](https://travis-ci.org/hiro4bbh/hako.rb)

Copyright 2017- Tatsuhiro Aoshima (hiro4bbh@gmail.com).

## What is hako.rb?
hako.rb is a simple data manipulation library written in Ruby, which
provides useful boxes for your data.
hako.rb has the following features:

- linear algebra support with OpenBLAS/LAPACK
- data frame support
- descriptive statistics support: under development
- plot engine: under development

## How to use hako.rb?
Currently, hako.rb is extremely unstable, so there is no gem for hako.rb
or installation scripts for deployment.

You can use hako.rb on macOS from GitHub, as the following:

```bash
# Get latest hako.rb from GitHub.
git clone https://github.com/hiro4bbh/hako.rb
cd hako.rb
# You can use OpenBLAS optimized for your machine.
brew install homebrew/science/openblas --build-from-source
# Use latest Ruby (currently tested on version 2.4.0p0).
brew install ruby
# Install FFI for OpenBLAS interface.
gem install ffi
# Happy hacking with hako.rb :)
./bin/hako.rb
```

You can see yardoc at http://www.rubydoc.info/github/hiro4bbh/hako.rb .
__WARNING: yardoc has many bugs for hako.rb documentation, be careful!!__
