#!/bin/bash

# Use this to start Blast locally in such a way that you can start a remote shell with `./connect-debug.sh`.

source .env

elixir --sname $NODE --cookie $COOKIE -S mix phx.server
