# test-chart-releaser
How to use this:

1. Keep file based helm charts in the charts folder.
2. Run the following if you increment a chart version. Please note that you need a token that can create releases in the repo:
```
./scripts/chart_publish.sh YOURTOKEN
```
At this point your chart is already published as a github release

3. Push your changes into main so that your updated index is uploaded and the page is built. Please note that the repo doesnt contain the helm charts, they are uploaded as releases and the index file points to them.
4. After the new github page is built run
 ```
 helm repo add test-chart-releaser https://adamma-da.github.io/test-chart-releaser/
 helm repo update test-chart-releaser
 helm search repo test-chart-releaser -l
 ```