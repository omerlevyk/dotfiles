#!/bin/bash

UP=$(awk '{print int($1/3600)}' /proc/uptime)
echo "󰔟 ${UP}h"
