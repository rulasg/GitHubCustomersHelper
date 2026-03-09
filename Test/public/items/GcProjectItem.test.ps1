function Test_GetGcProjectItem_SUCCESS{

    MockCall_GetAllItems

    $result = Get-GcProjectItem -ItemId "PVTI_lADOAOnouM4AzN5WzgaoV5A"

    Assert-AreEqual -Presented $result.Id            -Expected "PVTI_lADOAOnouM4AzN5WzgaoV5A"
    Assert-AreEqual -Presented $result.projectUrl    -Expected "https://github.com/orgs/githubcustomers/projects/2683"
    Assert-AreEqual -Presented $result.projectOwner  -Expected "githubcustomers"
    Assert-AreEqual -Presented $result.projectNumber -Expected 2683
}

