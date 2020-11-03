#! /bin/bash

readonly base_dir=$(cd `dirname $0` && cd .. && pwd)

cd ${base_dir}

./node_modules/.bin/remixd -s ./ --remix-ide https://remix.ethereum.org