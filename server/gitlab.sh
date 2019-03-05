#!/bin/bash
## Install: GitLab Runner (Free) ##
## PREQ: Docker CE

# PREQ: Docker CE

# Step #1: Pre-Package Requirements
apt-get install apt-transport-https ca-certificates gnupg2 software-properties-common

# Step #2: Add Repo KEY
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

# Step #3: Add Repo SRC

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

# Step 4: Install: Docker CE
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io

# GitLab Setup:

# Step #1: Add Repo KEY/SRC
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash

# Step #2: Install: GitLab Runner
apt-get install gitlab-runner
