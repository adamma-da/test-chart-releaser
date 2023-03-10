# test-chart-releaser
How to use this:

1. Keep file based helm charts in the charts folder.
2. Run the following if you increment a chart version. Please note that you need a token that can create releases in the repo:
```
./scripts/chart_publish.sh YOURTOKEN
```
3. Push your changes into main so that your updated index is uploaded and the page is built
4. After the new github page is built run
 ```
 test-chart-releaser https://adamma-da.github.io/test-chart-releaser/
 helm repo update test-chart-releaser
 helm search repo test-chart-releaser -l
 ```