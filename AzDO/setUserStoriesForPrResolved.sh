az extension add --name azure-devops

org=$2
echo 'org =' $org

echo $1 | az devops login --org $org

# get PR id using pipeline project/repo/branch
prId=$(az repos pr list --org $org -p "$(System.TeamProject)" --repository "$(Build.Repository.Name)" --source-branch $(Build.SourceBranch) --query [].pullRequestId -o tsv)
echo 'PR Id =' $prId

# get work item ids associated with this PR
workitemIds=$(az repos pr work-item list --org $org --id $prId --query [].id -o tsv)
echo 'work item ids =' $workitemIds

# loop over work items and set user stories to Resolved
for workitemId in $workitemIds
do
    echo $workitemId

    # get parent user story reference (comes as a url)
    userstoryUrl=$(az boards work-item show --org $org --id $workitemId --query "relations[?rel=='System.LinkTypes.Hierarchy-Reverse'].url" -o tsv)
    echo 'user story =' $userstoryUrl

    if [ ${#userstoryUrl} -gt 0 ]
    then
        # parse user story id out of url
        userstoryId="${userstoryUrl##*/}"
        echo 'user story id =' $userstoryId

        # set user story resolved
        az boards work-item update --org $org --id $userstoryId --state Resolved
    else
        # can we do anything with a bug?
        echo 'no user story found for work item' $workitemId
    fi
done