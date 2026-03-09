function Test_GetGcProjects {

    MockCallToString -Command 'gh api user --jq ".login"' -OutString 'testuser'

    MockCallJson -Command "Find-Project -owner githubcustomers -pattern creator:testuser" -filename "testuser-find-project.json"

    $projects = Get-GcProjects

    Assert-Count -Expected 16 -Presented $projects

    # Pick one random and check the structure
    $testProject = $projects."bit21"
    Assert-AreEqual -Expected "bit21" -Presented $testProject.Title
    Assert-AreEqual -Expected "githubcustomers" -Presented $testProject.Owner
    Assert-AreEqual -Expected 2683 -Presented $testProject.ProjectNumber
    Assert-AreEqual -Expected "https://github.com/orgs/githubcustomers/projects/2683" -Presented $testProject.Url

}