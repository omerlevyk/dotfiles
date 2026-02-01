sudo dpkg-reconfigure keyboard-configuration
sudo service keyboard-setup restart
sudo udevadm trigger --subsystem-match=input --action=change
