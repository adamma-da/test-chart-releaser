# test-chart-releaser

cr upload -b https://api.github.com/ -u https://uploads.github.com -c main -p charts --owner adamma-da --skip-existing -r test-chart-releaser --token 

cr index --pages-branch main -b https://api.github.com/ -u https://uploads.github.com -i docs/index.yaml -r test-chart-releaser -p charts --owner adamma-da --token