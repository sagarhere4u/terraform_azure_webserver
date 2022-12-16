#!/bin/bash
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo systemctl restart apache2
sudo systemctl enable apache2
