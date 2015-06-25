#hugo -t casper
git add -A
git commit -m "Updating site" && git push origin master
git subtree push --prefix=public git@github.com:netbrain/me.git gh-pages
