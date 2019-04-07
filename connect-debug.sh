#!/bin/bash

source .env

iex --sname client --cookie $COOKIE --remsh $NODE@$HOST -e "Node.connect(:$NODE@$HOST)"
