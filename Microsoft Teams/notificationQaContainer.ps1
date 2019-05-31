# this script should be included in a build pipeline using a PowerShell script task

param (
    $message,           # Build.SourceVersionMessage
    $branch,            # Build.SourceBranch
    $username,          # the user name that shows on the Slack message
    $webhookuri,        # the Slack web hook to call
    $containerUrl,      # should be set by a prior task (typically the one that creates the instance in ACI)
    $imageName,         # the ACI image name
    $buildId,           # AzDO build id
    $cleanupUrl,        # the entry point to the cleanup function (including the function authentication code)
    $title,             # the title that will be presented on the confirmation web page
    $acrRegistry,       # the target Azure Container Registry
    $acrRepository,     # the target repository in the acrRegistry
    $aciResourceGroup,  # the target resource group for the ACI instance of the image
    $project,           # the team project
    $targetBranch,      # the target branch for the merge
    $team               # the name of the AzDO team where the work is being assigned (used to determine the current iteration)
)

$text = "Container (ACI) for branch _$branch _ deployed:\n\n*$message*"
#Write-Host $text

if ('$(Build.SourceBranchName)' -eq 'master')
{
    $notification = "{
        ""@context"": ""https://schema.org/extensions"",
        ""@type"": ""MessageCard"",
        ""themeColor"": ""0072C6"",
        ""title"": ""B2B Test"",
        ""text"": ""$text"",
        ""sections"": [
            { ""text"": ""$(Build.SourceVersionMessage)""}
        ],
        ""potentialAction"": [
            {
                ""@type"": ""OpenUri"",
                ""name"": ""Launch"",
                ""targets"": [
                    { ""os"": ""default"", ""uri"": ""http://$container"" }
                ]
            }
        ]
    }"
}
else
{
    $notification = "{
        ""@context"": ""https://schema.org/extensions"",
        ""@type"": ""MessageCard"",
        ""themeColor"": ""0072C6"",
        ""title"": ""B2B Test"",
        ""text"": ""$text&nbsp;$(Build.SourceVersionMessage)"",
        ""sections"": [
            { ""text"": ""$(Build.SourceVersionMessage)""}`
        ],
        ""potentialAction"": [
            {
                ""@type"": ""OpenUri"",
                ""name"": ""Launch"",
                ""targets"": [
                    { ""os"": ""default"", ""uri"": ""http://$container"" }
                ]
            },
            {
                ""@type"": ""OpenUri"",
                ""name"": ""Delete this container and image"",
                ""targets"": [
                    { ""os"": ""default"", ""uri"": ""$(cleanupUrl)&container=$container&image=$(Build.BuildId)"" }
                ]
            }
        ]
    }"
}

Invoke-RestMethod -Uri $webhookuri -Method POST -Body $notifcation