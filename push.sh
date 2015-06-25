#!/bin/bash
hugo -t casper
git add -A
git commit -m "Updating site" && git push
#git subtree push --prefix=public git@github.com:netbrain/netbrain.github.com.git master
