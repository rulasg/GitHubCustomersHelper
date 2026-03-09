function Test_GetProjectItems_Success{

    MockCall_GetAllItems
    MockCall_GetGcReposMy

    # All 
    # Act
    $result = Get-GcProjectItems
    # Assert
    Assert-Count -Expected 5 -Presented $result

    # IncludeDone
    # Act
    $result = Get-GcProjectItems -IncludeDone
    # Assert
    Assert-Count -Expected 6 -Presented $result

    # RepositoryName
    # Act
    $result = Get-GcProjectItems -RepositoryName "kk"
    # Assert
    Assert-Count -Expected 2 -Presented $result

    # ProjectNumber
    # Act
    $result = Get-GcProjectItems -ProjectNumber 2683
    # Assert
    Assert-Count -Expected 2 -Presented $result
    Assert-Contains -Presented $result.id -Expected "PVTI_lADOAOnouM4AzN5Wzgml8mc"
    Assert-Contains -Presented $result.id -Expected "PVTI_lADOAOnouM4AzN5WzgmP5nc"
    
    # Filter
    # Act
    $result = Get-GcProjectItems -Filter "Demo"
    # Assert
    Assert-Count -Expected 1 -Presented $result
    Assert-Contains -Presented $result.id -Expected "PVTI_lADOAOnouM4AzN5WzgmP5nc"


}

function MockCall_GetProject($ProjectNumber){
        MockCallJson -Command "Get-ProjectItems -owner githubcustomers -projectNumber $ProjectNumber -IncludeDone" -filename "get-projectitems-githubcustomers-$ProjectNumber.json"
}

function GetMockFiles($ProjectNumber){
    enable-invokeCommandAliasModule

    $cmd = "Get-ProjectItems -owner githubcustomers -projectNumber $ProjectNumber -IncludeDone -Force"
    
    save-invokeAsMockFile $cmd -FileName "get-projectitems-githubcustomers-$ProjectNumber.json"
}

function MockCall_GetAllItems{

    # GetMyHandle
    MockCallToString -Command 'gh api user --jq ".login"' -OutString 'testuser'
    
    # Get-AllItems
    MockCallJson -Command "Find-Project -owner githubcustomers -pattern creator:testuser" -filename "testuser-find-project-3.json"
    MockCall_GetProject 2683 ; MockCall_GetProject 2988 ; MockCall_GetProject 3023

}