#!/bin/bash
HOSTNAME="<PLACEHOLDER>"
RUNNER_GROUP="<PLACEHOLDER>"
RUNNER_LABELS="<PLACEHOLDER>"
GITHUB_PAT="<PLACEHOLDER>"
ADMIN_SSH_AUTHORIZED_KEYS="<PLACEHOLDER>"
ADMIN_PASSWORD="<PLACEHOLDER>"
PATH="/opt/homebrew/bin/:$PATH"

echo "##### BEGIN startup script #####"

# recreate empty  action-runners directory
/bin/rm -rf /Users/admin/actions-runner 
/bin/mkdir /Users/admin/actions-runner 

# download runner config
cd /Users/admin/actions-runner
curl -o actions-runner-osx-arm64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-osx-arm64-2.331.0.tar.gz
/usr/bin/tar xzf ./actions-runner-osx-arm64-2.331.0.tar.gz

# retrieve runner token
GITHUB_TOKEN=$(curl -k -X POST -H "Authorization: Bearer $GITHUB_PAT" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/belgianmobileid/actions/runners/registration-token | jq -r .token)
# run runner config
/Users/admin/actions-runner/config.sh --unattended --url https://github.com/belgianmobileid --token $GITHUB_TOKEN --name $HOSTNAME --runnergroup $RUNNER_GROUP --labels $RUNNER_LABELS --replace
# install github runner as service and run
/Users/admin/actions-runner/svc.sh install
/Users/admin/actions-runner/svc.sh start

# ssh configuration
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config.d/00-disable-passwords.conf
echo $ADMIN_SSH_AUTHORIZED_KEYS | sudo tee -a /Users/admin/.ssh/authorized_keys

# install necessary packages with brew
if [[ $(command -v brew) == "" ]]; then
    echo "📦 Homebrew command not detected -> Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "📦 Homebrew already installed ✅"
fi
# update brew 
brew update 

if ! brew list mint &> /dev/null; then
    echo "📦 Homebrew mint is not installed. Installing now..."
    brew install mint
else
    echo "📦 Homebrew mint is already installed ✅"
fi
if ! brew list coreutils &> /dev/null; then
    echo "📦 Homebrew coreutils is not installed. Installing now..."
    brew install coreutils
else
    echo "📦 Homebrew coreutils is already installed ✅"
fi
if [[ $(command -v `brew list | grep lfs`) == "" ]]; then
    echo "📦 Installing git-lfs dependency"
    brew install git-lfs
    echo "📦 Pulling lfs data"
    git lfs pull
else
    echo "📦 git-lfs already installed ✅"
fi
if [[ $(command -v `brew list | grep xcodes`) == "" ]]; then
    echo "📦 Installing xcodes dependency"
    brew install xcodesorg/made/xcodes
else
    echo "📦 xcodes already installed ✅"
fi

# change admin password
/usr/bin/dscl . -passwd /Users/admin admin $ADMIN_PASSWORD

echo "##### END startup script #####"