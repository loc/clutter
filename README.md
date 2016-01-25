## Build Instructions
```
brew install boost
make
```

## Release Instructions
1. Tag the commit on the `master` branch

        git tag v0.7.0
        git push origin head --tags

2. Switch to the `gh-pages` branch and create release notes to your liking.

        git checkout gh-pages
        vim RELEASE.html

3. Run the release script and watch the magic happen

        ./scripts/release RELEASE.HTML "v0.7.0 this is the message title"

4. Double check the appcast and ship.

        git status
        head appcast.xml
        git commit -am "releasing v0.7.0"
        git push origin head





