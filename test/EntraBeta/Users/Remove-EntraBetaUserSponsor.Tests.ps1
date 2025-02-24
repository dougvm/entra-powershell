# ------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All Rights Reserved.  Licensed under the MIT License.  See License in the project root for license information.
# ------------------------------------------------------------------------------

BeforeAll {  
    if((Get-Module -Name Microsoft.Entra.Beta.Users) -eq $null){
        Import-Module Microsoft.Entra.Beta.Users    
    }
    Import-Module (Join-Path $PSScriptRoot "..\..\Common-Functions.ps1") -Force

    Mock -CommandName Invoke-GraphRequest -MockWith {} -ModuleName Microsoft.Entra.Beta.Users
}

Describe "Remove-EntraBetaUserSponsor" {
    Context "Test for Remove-EntraBetaUserSponsor" {
        It "Should fail when UserId is empty string value" {
            { Remove-EntraBetaUserSponsor -UserId "" -SponsorId "sponsor123" } | 
                Should -Throw "Cannot bind argument to parameter 'UserId' because it is an empty string."
        }

        It "Should fail when UserId is empty" {
            { Remove-EntraBetaUserSponsor -UserId } | 
                Should -Throw "Missing an argument for parameter 'UserId'. Specify a parameter of type 'System.String' and try again."
        }

        It "Should fail when SponsorId is empty string value" {
            { Remove-EntraBetaUserSponsor -UserId "user123" -SponsorId "" } | 
                Should -Throw "Cannot bind argument to parameter 'SponsorId' because it is an empty string."
        }

        It "Should fail when SponsorId is empty" {
            { Remove-EntraBetaUserSponsor -UserId "user123" -SponsorId } | 
                Should -Throw "Missing an argument for parameter 'SponsorId'. Specify a parameter of type 'System.String' and try again."
        }

        It "Should call Invoke-GraphRequest with correct parameters" {
            $userId = "00aa00aa-bb11-cc22-dd33-44ee44ee44e"
            $sponsorId = "10aa00aa-bb11-cc22-dd33-44ee44ee44e"
            
            Remove-EntraBetaUserSponsor -UserId $userId -SponsorId $sponsorId
            Should -Invoke -CommandName Invoke-GraphRequest -ModuleName Microsoft.Entra.Beta.Users -Times 1 -Exactly
        }

        It "Should accept DirectoryObjectId as alias for SponsorId" {
            $userId = "00aa00aa-bb11-cc22-dd33-44ee44ee44e"
            $dirObjectId = "10aa00aa-bb11-cc22-dd33-44ee44ee44e"
            
            Remove-EntraBetaUserSponsor -UserId $userId -DirectoryObjectId $dirObjectId
            Should -Invoke -CommandName Invoke-GraphRequest -ModuleName Microsoft.Entra.Beta.Users -Times 1 -Exactly
        }
    }
}
