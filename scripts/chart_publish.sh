#!/bin/sh
#set -x

# Set up script variables
CHARTS_DIR=./charts/

HELMREPO_NAME=test-chart-releaser
GITREPO_NAME=test-chart-releaser
GITREPO_OWNER=adamma-da

PUBLISH_BRANCH=main
PUBLISH_FOLDER="publish"
PAGES_BRANCH=main


mkdir $PUBLISH_FOLDER
helm repo add $HELMREPO_NAME https://$GITREPO_OWNER.github.io/$GITREPO_NAME/

git config user.email "${GITHUB_ACTOR}@dummy.com"
git config user.name "${GITHUB_ACTOR}"


# Loop through the helm charts in the designated folder
for chart in $CHARTS_DIR/*; do
    # Get the chart name and version from the Chart.yaml file and load them into vars
    chart_name=$(yq eval '.name' $chart/Chart.yaml)
    chart_version=$(yq eval '.version' $chart/Chart.yaml)

    # Check if the chart version has already been pushed to the repo
    if helm search repo $HELMREPO_NAME/$chart_name -o yaml  -l | grep -w "version: $chart_version"; then
        echo "Chart $chart_name version $chart_version already exists in repository $HELMREPO_NAME"
    else
        # Handling the version incremented chart
        helm package $chart -d $PUBLISH_FOLDER
        cr upload -b https://api.github.com/ -u https://uploads.github.com --skip-existing -c $PUBLISH_BRANCH -r $GITREPO_NAME  -p $PUBLISH_FOLDER --owner $GITREPO_OWNER --token $1
        echo "Chart $chart_name version $chart_version has been pushed to repository $HELMREPO_NAME"
        #helm repo index publish --url https://github.com/adamma-da/test-chart-releaser/releases/download/$chart_name-$chart_version/  --merge docs/index.yaml

    fi
done

#mv publish/index.yaml docs/index.yaml
# this doesnt work due to a bug in CR.
#
echo "Creating pull request as user $GITHUB_ACTOR"
cr index --pr --pages-branch $PAGES_BRANCH -b https://api.github.com/ -u https://uploads.github.com -i docs/index.yaml -r $GITREPO_NAME  -p $PUBLISH_FOLDER --owner $GITREPO_OWNER --token $1
#
rm -rf $PUBLISH_FOLDER