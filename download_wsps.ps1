$farm = Get-SPFarm

$loc = "C:\SharePoint\solutions"

foreach($solution in $farm.Solutions){

$solution = $farm.Solutions[$solution.Name]
$file = $solution.SolutionFile
$file.SaveAs($loc + '\' + $solution.Name)
}
