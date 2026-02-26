#!/bin/bash
HOSTNAME="<PLACEHOLDER>"
RUNNER_GROUP="<PLACEHOLDER>"
RUNNER_LABELS="<PLACEHOLDER>"
GITHUB_PAT="<PLACEHOLDER>"
ADMIN_SSH_AUTHORIZED_KEYS="<PLACEHOLDER>"
ADMIN_PASSWORD="<PLACEHOLDER>"
PATH="/opt/homebrew/bin/:$PATH"

echo "############ BEGIN SCRIPT ##########"
# set ssh keys for admin user
echo $ADMIN_SSH_AUTHORIZED_KEYS | sudo tee -a /Users/admin/.ssh/authorized_keys

# no password authentication via ssh
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config.d/00-disable-passwords.conf
echo "############ STAP 1 ##########"
# install necessary packages with brew
if [[ $(command -v brew) == "" ]]; then
    echo "📦 Homebrew command not detected -> Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "📦 Homebrew already installed ✅"
fi
echo "############ STAP 2 ##########"
# update & upgrade brew packages
/opt/homebrew/bin/brew update && /opt/homebrew/bin/brew upgrade

# uninstall default unecessary packages from brew
/opt/homebrew/bin/brew uninstall xcodes
echo "############ STAP 3 ##########"
for package in xcodes mint xcodesorg/made/xcodes git-lfs coreutils
do
    if ! brew list $package &> /dev/null; then
        echo "📦 Homebrew $package is not installed. Installing now..."
        brew install $package
    else
        echo "📦 Homebrew $package is already installed ✅"
    fi
done

echo "############ STAP 4 ##########"

# recreate empty  action-runners directory
/bin/rm -rf /Users/admin/actions-runner && /bin/mkdir /Users/admin/actions-runner 
echo "############ STAP 5 ##########"
# download runner config
cd /Users/admin/actions-runner && curl -o actions-runner-osx-arm64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-osx-arm64-2.331.0.tar.gz && /usr/bin/tar xzf ./actions-runner-osx-arm64-2.331.0.tar.gz
echo "############ STAP 6 ##########"
# retrieve runner token
#GITHUBTOKEN=$(curl -k -X POST -H "Authorization: Bearer $GITHUB_PAT" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/belgianmobileid/actions/runners/registration-token | jq -r .token)
echo "############ STAP 7 ##########"
# run runner config
#/Users/admin/actions-runner/config.sh --unattended --url https://github.com/belgianmobileid --token $GITHUBTOKEN --name $HOSTNAME --runnergroup $RUNNGERGROUP --labels $RUNNERLABELS --replace
echo "############ STAP 8 ##########"
# install github runner as service and run
#/Users/admin/actions-runner/svc.sh install && /Users/admin/actions-runner/svc.sh start

echo "############ STAP 9 ##########"

# # change admin password
#/usr/bin/dscl . -passwd /Users/admin admin $ADMIN_PASSWORD

echo "############ EINDE SCRIPT ##########"