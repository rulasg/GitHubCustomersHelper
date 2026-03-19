function Test_GetGcProjects {

    MockCallToString -Command 'gh api user --jq ".login"' -OutString 'testuser'

    MockCallJson -Command "Find-Project -owner githubcustomers -pattern creator:testuser" -filename "testuser-find-project.json"

    $projects = Get-GcProject

    Assert-Count -Expected 16 -Presented $projects

    # Pick one random and check the structure
    $testProject = $projects."BiT21"
    Assert-AreEqual -Expected "BiT21" -Presented $testProject.Title
    Assert-AreEqual -Expected "githubcustomers" -Presented $testProject.Owner
    Assert-AreEqual -Expected 2683 -Presented $testProject.ProjectNumber
    Assert-AreEqual -Expected "https://github.com/orgs/githubcustomers/projects/2683" -Presented $testProject.Url

}

function Test_GetGcProjects_Success{

    # Arrange
    MockCall_GetGcProjects

    # Act
    $result = Get-GcProject

    # Assert
    Assert-Count -Expected 3 -Presented $result.Keys
    Assert-Contains -Presented $result.Keys -Expected "Customer_1"
    Assert-Contains -Presented $result.Keys -Expected "_TEMPLATE__Customer_Project"
    Assert-Contains -Presented $result.Keys -Expected "BiT21"
    
    # Verify structure of one project
    Assert-AreEqual -Expected "BiT21" -Presented $result.BiT21.Title
    Assert-AreEqual -Expected "githubcustomers" -Presented $result.BiT21.Owner
    Assert-AreEqual -Expected 2683 -Presented $result.BiT21.ProjectNumber
    Assert-AreEqual -Expected "https://github.com/orgs/githubcustomers/projects/2683" -Presented $result.BiT21.Url
}

function Test_GetGcProjects_WithForce{

    # Arrange
    MockCall_GetGcProjects

    # Act - First call
    $result1 = Get-GcProject
    # Act - Second call without Force (should use cache)
    $result2 = Get-GcProject
    # Act - Third call with Force (should refresh)
    $result3 = Get-GcProject -Force

    # Assert
    Assert-Count -Expected 3 -Presented $result1.Keys
    Assert-Count -Expected 3 -Presented $result2.Keys
    Assert-Count -Expected 3 -Presented $result3.Keys
}

function MockCall_GetGcProjects{
    MockCallToString -Command 'gh api user --jq ".login"' -OutString 'testuser'
    MockCallJson -Command "Find-Project -owner githubcustomers -pattern creator:testuser" -filename "testuser-find-project-3.json"
}
