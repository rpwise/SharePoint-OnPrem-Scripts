# count bot records

$weburl = "http://servername/"
$listName = "List Name"

write-host "Connecting to SharePoint site..."
$web = get-spweb $weburl
write-host "Connected to" $web.title

write-host "Connecting to list..."
$list = $web.lists[$listName]
write-host "Connected to" $list.title
write-host ""


$deleteCount = 0
$itemCount = $list.items.count
write-host "List item count:" $itemCount
write-host "Getting bot count..."


# Batch Deletion using CAML
$query = New-Object Microsoft.SharePoint.SPQuery;
$query.ViewAttributes = "Scope='Recursive'";
$query.RowLimit = 2000;
$query.Query = '<Where><IsNull><FieldRef Name="First_x0020_Name" /></IsNull></Where>';

$deleteCount = 0;
$listId = $list.ID;
[System.Text.StringBuilder]$batchXml = New-Object "System.Text.StringBuilder";
$batchXml.Append("<?xml version=`"1.0`" encoding=`"UTF-8`"?><Batch>");
$command = [System.String]::Format( "<Method><SetList>{0}</SetList><SetVar Name=`"ID`">{1}</SetVar><SetVar Name=`"Cmd`">Delete</SetVar></Method>", $listId, "{0}" );

do
{
    $listItems = $list.GetItems($query)
    $query.ListItemCollectionPosition = $listItems.ListItemCollectionPosition
    foreach ($item in $listItems)
    {
        if($item -ne $null){$batchXml.Append([System.String]::Format($command, $item.ID.ToString())) | Out-Null;$deleteCount++;}
    }

    write-host "Current deletion count:" $deleteCount
}
while ($query.ListItemCollectionPosition -ne $null)

$batchXml.Append("</Batch>");
$deleteCount;

# runs the bulk deletion
$web.ProcessBatchData($batchXml.ToString()) | Out-Null;

Write-Host "Total deletion count:" $deleteCount
write-host "Script completed successfully"
