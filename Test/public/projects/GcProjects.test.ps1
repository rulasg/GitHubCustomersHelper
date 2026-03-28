function Test_GetGcProjects {

    # Arrange
    MockCall_GetAllItems

    # Act
    $projects = Get-GcProject

    Assert-Count -Expected 3 -Presented $projects

    # Pick one random and check the structure
    $testProject = $projects | Where-Object {$_.Title -eq "BiT21"}
    Assert-AreEqual -Expected "BiT21" -Presented $testProject.Title
    Assert-AreEqual -Expected "githubcustomers" -Presented $testProject.Owner
    Assert-AreEqual -Expected 2683 -Presented $testProject.ProjectNumber
    Assert-AreEqual -Expected "https://github.com/orgs/githubcustomers/projects/2683" -Presented $testProject.Url

}

function Test_GetGcProjects_Success{

    # Arrange
    MockCall_GetAllItems

    # Act
    $result = Get-GcProject

    # Assert
    Assert-Count -Expected 3 -Presented $result
    Assert-Contains -Presented $result.Title -Expected "Customer_1"
    Assert-Contains -Presented $result.Title -Expected "[TEMPLATE] Customer Project"
    Assert-Contains -Presented $result.Title -Expected "BiT21"
    
    # Verify structure of one project
    $testProject = $result | Where-Object {$_.Title -eq "BiT21"}

    Assert-AreEqual -Expected "BiT21" -Presented $testProject.Title
    Assert-AreEqual -Expected "githubcustomers" -Presented $testProject.Owner
    Assert-AreEqual -Expected 2683 -Presented $testProject.ProjectNumber
    Assert-AreEqual -Expected "https://github.com/orgs/githubcustomers/projects/2683" -Presented $testProject.Url
}

function Test_GetGcProjects_Success_SingleProject{

    # Arrange
    MockCall_GetAllItems

    # Act
    $result = Get-GcProject -ProjectName "BiT21"


    Assert-AreEqual -Expected "BiT21" -Presented $result.Title
    Assert-AreEqual -Expected "githubcustomers" -Presented $result.Owner
    Assert-AreEqual -Expected 2683 -Presented $result.ProjectNumber
    Assert-AreEqual -Expected "https://github.com/orgs/githubcustomers/projects/2683" -Presented $result.Url
}