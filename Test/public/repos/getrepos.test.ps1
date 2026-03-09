function Test_GetGcReposMy_Success{

    # Arrange
    MockCall_GetGcReposMy

    # Act
    $result = Get-GcReposMy

    # Assert
    Assert-Count -Expected 22 -Presented $result.Keys
    Assert-Contains -Presented $result.Keys -Expected "kk"
    Assert-Contains -Presented $result.Keys -Expected "bit21"
    
    # Verify structure of one repo
    Assert-AreEqual -Expected "bit21" -Presented $result.bit21.name
    Assert-AreEqual -Expected "https://github.com/githubcustomers/bit21" -Presented $result.bit21.url
}

function Test_GetGcReposMy_WithForce{

    # Arrange
    MockCall_GetGcReposMy

    # Act - First call
    $result1 = Get-GcReposMy
    # Act - Second call without Force (should use cache)
    $result2 = Get-GcReposMy
    # Act - Third call with Force (should refresh)
    $result3 = Get-GcReposMy -Force

    # Assert
    Assert-Count -Expected 22 -Presented $result1.Keys
    Assert-Count -Expected 22 -Presented $result2.Keys
    Assert-Count -Expected 22 -Presented $result3.Keys
}

function Test_GetGcRepos_Success{

    # Arrange
    MockCall_SearchRepos

    # Act
    $result = Get-GcRepos -PropertyValue "testuser"

    # Assert
    Assert-Count -Expected 22 -Presented $result.Keys
    Assert-Contains -Presented $result.Keys -Expected "kk"
    Assert-Contains -Presented $result.Keys -Expected "bit21"
}

function MockCall_GetGcReposMy{
    # GetMyHandle
    MockCallToString -Command 'gh api user --jq ".login"' -OutString 'testuser'
    
    # SearchRepos
    MockCall_SearchRepos
}

function MockCall_SearchRepos{
    MockCallJson -Command 'Invoke-SearchRepo -SearchString "org:githubcustomers props.SolutionEngineer:testuser"' -filename "testuser-search-repos.json"
}
