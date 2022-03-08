#!/bin/bash
dpkg -l|grep xunyou|awk '{print $2"="$3}'

