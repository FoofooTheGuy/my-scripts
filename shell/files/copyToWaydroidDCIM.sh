#! /bin/bash

echo 'give me file'
#/home/user/.local/share/waydroid/data/media/0/DCIM
read file

echo sudo cp $file $(eval echo ~$USER)/.local/share/waydroid/data/media/0/DCIM
sudo cp $file $(eval echo ~$USER)/.local/share/waydroid/data/media/0/DCIM
