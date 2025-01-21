# ------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  
#  All Rights Reserved.  
#  Licensed under the MIT License.  
#  See License in the project root for license information.
# ------------------------------------------------------------------------------

BeforeAll {
    if ((Get-Module -Name Microsoft.Entra.DirectoryManagement) -eq $null) {
        Import-Module Microsoft.Entra.DirectoryManagement
    }
    Import-Module (Join-Path $PSScriptRoot "..\..\Common-Functions.ps1") -Force

    $scriptblock = {
        return @(
            [PSCustomObject]@{
                "DisplayName"     = "ADC Administrative Unit"
                "Id"              = "aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb"
                "DeletedDateTime" = "10/21/2024 8:27:52 AM"
                "Description"     = "ADC Administrative Unit"
            }
        )
    }

    Mock -CommandName Get-MgDirectoryDeletedItemAsAdministrativeUnit -MockWith $scriptblock -ModuleName Microsoft.Entra.DirectoryManagement
}

Describe "Get-EntraDeletedAdministrativeUnit" {
    Context "Test for Get-EntraDeletedAdministrativeUnit" {
        It "Should return all administrative units" {
            $result = Get-EntraDeletedAdministrativeUnit
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke -CommandName Get-MgDirectoryDeletedItemAsAdministrativeUnit -ModuleName Microsoft.Entra.DirectoryManagement -Times 1
        }

        It "Should return specific administrative unit by searchstring" {
            $result = Get-EntraDeletedAdministrativeUnit -SearchString 'ADC Administrative Unit'
            $result | Should -Not -BeNullOrEmpty
            $result.DisplayName | Should -Be 'ADC Administrative Unit'
            Should -Invoke -CommandName Get-MgDirectoryDeletedItemAsAdministrativeUnit -ModuleName Microsoft.Entra.DirectoryManagement -Times 1
        }

        It "Should return specific administrative unit by filter" {
            $result = Get-EntraDeletedAdministrativeUnit -Filter "DisplayName -eq 'ADC Administrative Unit'"
            $result | Should -Not -BeNullOrEmpty
            $result.DisplayName | Should -Be 'ADC Administrative Unit'
            Should -Invoke -CommandName Get-MgDirectoryDeletedItemAsAdministrativeUnit -ModuleName Microsoft.Entra.DirectoryManagement -Times 1
        }

        It "Should return top administrative unit" {
            $result = Get-EntraDeletedAdministrativeUnit -Top 1
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke -CommandName Get-MgDirectoryDeletedItemAsAdministrativeUnit -ModuleName Microsoft.Entra.DirectoryManagement -Times 1
        }

        It "Property parameter should work" {
            $result = Get-EntraDeletedAdministrativeUnit -Property "DisplayName"
            $result | Should -Not -BeNullOrEmpty
            $result.DisplayName | Should -Be "ADC Administrative Unit"
            Should -Invoke -CommandName Get-MgDirectoryDeletedItemAsAdministrativeUnit -ModuleName Microsoft.Entra.DirectoryManagement -Times 1
        }

        It "Should fail when Property is empty" {
            { Get-EntraDeletedAdministrativeUnit -Property } | Should -Throw "Missing an argument for parameter 'Property'*"
        }

        It "Should contain 'User-Agent' header" {
            $userAgentHeaderValue = "PowerShell/$psVersion EntraPowershell/$entraVersion Get-EntraDeletedAdministrativeUnit"
            $result = Get-EntraDeletedAdministrativeUnit -Filter "DisplayName -eq 'ADC Administrative Unit'"
            $result | Should -Not -BeNullOrEmpty
            $userAgentHeaderValue = "PowerShell/$psVersion EntraPowershell/$entraVersion Get-EntraDeletedAdministrativeUnit"
            Should -Invoke -CommandName Get-MgDirectoryDeletedItemAsAdministrativeUnit -ModuleName Microsoft.Entra.DirectoryManagement -Times 1 -ParameterFilter {
                $Headers.'User-Agent' | Should -Be $userAgentHeaderValue
                $true
            }
        }

        It "Should execute successfully without throwing an error" {
            # Disable confirmation prompts
            $originalDebugPreference = $DebugPreference
            $DebugPreference = 'Continue'

            try {
                # Act & Assert: Ensure the function doesn't throw an exception
                { Get-EntraDeletedAdministrativeUnit -Debug } | Should -Not -Throw
            }
            finally {
                # Restore original confirmation preference
                $DebugPreference = $originalDebugPreference
            }
        }
    }
}