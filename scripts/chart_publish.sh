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
git config user.email "machine@digitalasset.com"
git config user.name "machine-da"


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
        helm repo index publish --url https://github.com/adamma-da/test-chart-releaser/releases/download/$chart_name-$chart_version/  --merge docs/index.yaml

    fi
done

mv publish/index.yaml docs/index.yaml

# CR index doesnt work for multiple reasons. One being it uses a folder to create an index and it has no file merge capabilities therefore only the files present in the folder would be added to the index.
#cr index --pr --pages-branch $PAGES_BRANCH -b https://api.github.com/ -u https://uploads.github.com -i docs/index.yaml -r $GITREPO_NAME  -p $PUBLISH_FOLDER --owner $GITREPO_OWNER --token $1

rm -rf $PUBLISH_FOLDER

if [[ -z $(git status -s) ]]; then
  echo "No changes to push"
else
  echo "Pushing changes"
  git add .
  git checkout -b "$PUBLISH_BRANCH" --track
  git commit -m "Updated index.yaml file so that it contains the newly pushed helm charts"
  git push -f origin "$PUBLISH_BRANCH"
  current_pr_closed=$(gh jq --run "gh pr status --json closed -q '.currentBranch.closed'")
  if [[ -z $current_pr_closed ]] || [[ $current_pr_closed == "true" ]] ; then
    echo "Opening new PR."
    gh pr create --fill
  else
    echo "PR already exists."
  fi
fi