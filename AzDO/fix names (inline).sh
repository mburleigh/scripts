# this is a kludge but the image name is forced to lowercase and this is the easiest way to get a value that will work downstream
s=$(Build.SourceBranchName)
lc=${s,,}
echo "##vso[task.setvariable variable=imageName]$lc"

# this is a kludge but the repository name is forced to lowercase and this is the easiest way to get a value that will work downstream
s=$(Build.Repository.Name)
lc=${s,,}
echo "##vso[task.setvariable variable=acrRepository]$lc"
