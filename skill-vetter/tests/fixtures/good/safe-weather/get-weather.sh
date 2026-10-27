#!/usr/bin/env bash
# get-weather.sh - Fetch weather from wttr.in

CITY="${1:-London}"
curl -s "https://wttr.in/${CITY}?format=3"
