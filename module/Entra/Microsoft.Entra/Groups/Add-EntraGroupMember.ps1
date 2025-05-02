# ------------------------------------------------------------------------------ 
#  Copyright (c) Microsoft Corporation.  All Rights Reserved.  
#  Licensed under the MIT License.  See License in the project root for license information. 
# ------------------------------------------------------------------------------ 
function Add-EntraGroupMember {
    [CmdletBinding(DefaultParameterSetName = 'ByGroupIdAndMemberId', SupportsShouldProcess = $true)]
    param (
        [Alias('ObjectId')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $false, ParameterSetName = 'ByGroupIdAndMemberId', 
            HelpMessage = "Unique ID of the group. Should be a valid GUID value.")]
        [ValidateNotNullOrEmpty()]
        [Guid] $GroupId,
                
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, 
            HelpMessage = "Unique ID of the member to add to the group. You can add users, security groups, Microsoft 365 groups, devices, service principals, and organizational contacts to security groups. Only users can be added to Microsoft 365 groups.")]
        [Alias('RefObjectId', 'Id')]
        [ValidateNotNullOrEmpty()]
        [Guid] $MemberId
    )

    begin {
        # Ensure connection to Microsoft Entra
        if (-not (Get-EntraContext)) {
            $errorMessage = "Not connected to Microsoft Graph. Use 'Connect-Entra -Scopes Group.ReadWrite.All' to authenticate."
            Write-Error -Message $errorMessage -ErrorAction Stop
            return
        }
        
        # Get the Graph endpoint from the current environment
        $environment = (Get-EntraContext).Environment
        $graphEndpoint = (Get-EntraEnvironment | Where-Object Name -eq $environment).GraphEndPoint
        
        # Default to global endpoint if not found
        if (-not $graphEndpoint) {
            $graphEndpoint = "https://graph.microsoft.com"
            Write-Verbose "Using default Graph endpoint: $graphEndpoint"
        }
        else {
            Write-Verbose "Using environment-specific Graph endpoint: $graphEndpoint"
        }
    }

    PROCESS {
        try {
            # Get custom headers for Microsoft Graph API requests
            $customHeaders = New-EntraCustomHeaders -Command $MyInvocation.MyCommand
            
            # Set up the request parameters
            $params = @{
                Method      = "POST"
                Uri         = "/v1.0/groups/$GroupId/members/`$ref"
                Headers     = $customHeaders
                Body        = @{
                    "@odata.id" = "$graphEndpoint/v1.0/directoryObjects/$MemberId"
                } | ConvertTo-Json
                ContentType = "application/json"
            }
            
            # Debug output
            Write-Debug("============================ TRANSFORMATIONS ============================")
            Write-Debug("Uri : $($params.Uri)")
            Write-Debug("Method : $($params.Method)")
            Write-Debug("Body : $($params.Body)")
            Write-Debug("GroupId : $GroupId")
            Write-Debug("MemberId : $MemberId")
            Write-Debug("=========================================================================`n")
            
            # Add ShouldProcess to prevent accidental modifications
            if ($PSCmdlet.ShouldProcess("Add member '$MemberId' to group '$GroupId'")) {
                Write-Verbose "Adding member $MemberId to group $GroupId"
                
                # Make the API call
                $response = Invoke-MgGraphRequest @params
                
                # Create a custom object for output
                if ($null -eq $response) {
                    $result = [PSCustomObject]@{
                        GroupId  = $GroupId
                        MemberId = $MemberId
                        Status   = "Success"
                        Action   = "Added"
                    }
                    return $result
                }
                
                return $response
            }
        }
        catch {
            # Handle error messages based on the failure
            $statusCode = $null
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
                $statusCode = $_.Exception.Response.StatusCode.value__
            }
            
            if ($statusCode -eq 404) {
                Write-Error "Either group $GroupId or member $MemberId not found."
            }
            elseif ($statusCode -eq 403) {
                Write-Error "You don't have permission to add members to this group. To connect, use 'Connect-Entra -Scopes Group.ReadWrite.All'"
            }
            elseif ($statusCode -eq 400 -and $_.Exception.Message -match "One or more added object references already exist") {
                Write-Warning "Member $MemberId is already a member of group $GroupId."
            }
            else {
                Write-Error "Failed to add member: $_"
            }
        }
    }
}
Set-Alias -Name New-EntraGroupMember -Value Add-EntraGroupMember -Scope Global -Force
Set-Alias -Name Add-EntraGroupMembership -Value Add-EntraGroupMember -Scope Global -Force
