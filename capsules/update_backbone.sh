#!/data/data/com.termux/files/usr/bin/bash

source ~/capsules/core/backbone.env

for c in ~/capsules/*; do
    cp ~/capsules/core/backbone.env "$c"/
done

echo "Backbone aligned: $(date)"
