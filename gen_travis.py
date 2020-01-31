#!/usr/bin/env python

import json
import yaml

sdks = json.load(open('crawl/urls.json'))

config = {
  "services": "docker",
  "env": [ "ARCH=%s URL=%s" % (sdk['arch'], sdk['url']) for sdk in sdks],
  "install": "echo \"$DOCKER_PASSWORD\" | docker login -u \"$DOCKER_USERNAME\" --password-stdin",
  "script": "docker build --build-arg URL=$URL -t $DOCKER_REPO:$ARCH .",
  "after_success": "docker push $DOCKER_REPO:$ARCH"
}

yaml.dump(config, open('.travis.yml', 'w'), sort_keys=False)
