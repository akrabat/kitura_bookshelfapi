# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  @VM_NAME = "kitura-bookshelf" # name for Vagrant status and VirtualBox GUI

  # set vagrant name
  config.vm.define @VM_NAME, primary: true do |c|
  end

  # Select your Ubuntu: wily64 (15.10) or xenial64 (16.04)
  config.vm.box = "ubuntu/wily64"
  # config.vm.box = "ubuntu/xenial64"
  
  # Forward Kitura port
  config.vm.network 'forwarded_port', guest: 8090, host: 8090
  # Forward CouchDB port
  config.vm.network 'forwarded_port', guest: 5984, host: 5984

  # Set hostname
  config.vm.hostname = @VM_NAME + ".local"

  # Prevent Vagrant 1.7 from asking for the vagrant user's password
  config.ssh.insert_key = false

  # Uncomment this line if you want to use NFS for shared folders
  #config.vm.synced_folder ".", "/vagrant", type: "nfs"

  # VirtualBox configration
  config.vm.provider "virtualbox" do |vb|
    vb.name = @VM_NAME
    # vb.memory = 1024
    # vb.cpus = 2
    # vb.gui = true
  end

  # Prevents "stdin: is not a tty" on Ubuntu (https://github.com/mitchellh/vagrant/issues/1673)
  config.vm.provision "fix-no-tty", type: "shell" do |s|
      s.privileged = false
      s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  
  # install system packages as root user
  config.vm.provision 'shell', privileged: true, inline: <<-SHELL

###############################################################################
# Update apt
export DEBIAN_FRONTEND=noninteractive

# Add couchdb PPA
echo "========== Add CouchDB PPA =========="
apt-get -q -y install software-properties-common
add-apt-repository ppa:couchdb/stable -y
apt-get update

###############################################################################
# Fundamentals
echo "========== Installing baseline bits =========="
apt-get -q -y install vim autojump

###############################################################################
# Install swift deps
echo "========== Installing swift dependencies =========="
apt-get -q -y install clang libicu-dev


###############################################################################
# Install Kitura reqs
echo "========== Installing Kitura dependencies =========="
apt-get -q -y install openssl libssl-dev libcurl4-openssl-dev uuid-dev

# dtrace for provider.h
apt-get -q -y install systemtap-sdt-dev


###############################################################################
# Install CouchDB
echo "========== Installing CouchDB =========="
apt-get -q -y install couchdb


SHELL

  # items for vagrant user
  config.vm.provision 'shell', privileged: false, inline: <<-SHELL


###############################################################################
# Add autojump and history search to bashrc
if [ $(grep -c "autojump" .bashrc) -eq 0 ]; then
    cat << 'EOF' >> .bashrc
source /usr/share/autojump/autojump.bash

###############################################################################
# Personal preference: up & down map to history search once a command has been started.
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

EOF
    source .bashrc
fi


###############################################################################
# Install swiftenv & set up .profile
echo "========== Installing swiftenv =========="
cd /home/vagrant
if [ ! -d "swiftenv" ]; then
  echo "Install swiftenv"
  git clone https://github.com/kylef/swiftenv
fi

if [ $(grep -c "swiftenv" .profile) -eq 0 ]; then
    cat << 'EOF' >> .profile

export SWIFTENV_ROOT="$HOME/swiftenv"
export PATH="$SWIFTENV_ROOT/bin:$PATH"
eval "$(swiftenv init -)"

EOF

fi

###############################################################################
# add LD_LIBRARY_PATH to .profile
if [ $(grep -c "LD_LIBRARY_PATH" .profile) -eq 0 ]; then
    cat << 'EOF' >> .profile

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

EOF

fi

###############################################################################
# Setup CouchDb
echo "========== Setup CouchDB =========="
curl -s -X PUT http://localhost:5984/_config/admins/rob -d '"123456"'
/vagrant/scripts/seed_couchdb.sh --username=rob --password=123456


###############################################################################
# Install Swift
export SWIFTENV_ROOT="/home/vagrant/swiftenv"
export PATH="$SWIFTENV_ROOT/bin:$PATH"
eval "$(swiftenv init -)"

export SWIFT_VERSION=3.0
swiftenv install $SWIFT_VERSION
swiftenv local $SWIFT_VERSION


###############################################################################
echo ""
echo "All done"

SHELL

end
