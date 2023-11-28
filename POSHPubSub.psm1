<#
    Title: POSHPubSub
    Author: Event_Horizon / Event-Horizon
    Date: 19-11-19
    Updated: 23-11-27    
#>
function New-PubSubBroker($Name) {
    return @{Name = $Name; Queues = @{} };
}
$Global:GlobalPOSHPubSubBrokerString = "POSHPubSub"
$Global:GlobalPOSHPubSubBroker = New-PubSubBroker($GlobalPOSHPubSubBrokerString);
function Test-PubSubPath($PubSubPath) {
    $Pattern = "^(\S+\\)*\S+$";
    if ($PubSubPath -match $Pattern) {
        return $true;
    }
    return $false;
}
function New-Subscription($Subscription, $ScriptBlock, $PubSubBroker = $GlobalPOSHPubSubBroker) {
    $PubSubPath = $Subscription;
    if (-Not (Test-PubSubPath $PubSubPath)) { 
        Write-Error "Invalid Subscription path format."; 
        return; 
    }
    try {
        $CurrentBroker = $PubSubBroker;

        # Ensure the queue for the subscription path exists
        $CurrentBroker.Queues[$PubSubPath] = $CurrentBroker.Queues[$PubSubPath] -as [System.Collections.ArrayList] ?? @();

        # Generate a sequential number as the ID
        $SubscriptionId = $CurrentBroker.Queues[$PubSubPath].Count;
        
        $SubscriptionInfo = @{
            id = $SubscriptionId;
            ScriptBlock = $ScriptBlock;
        };

        # Add the script block to the subscription path
        $CurrentBroker.Queues[$PubSubPath] += $SubscriptionInfo;

        return $SubscriptionId;
    }
    catch {
        Write-Error "Failed to add subscription: $_";
        return;
    }
}

function Remove-Subscription($Subscription, $SubscriptionId, $PubSubBroker = $GlobalPOSHPubSubBroker) {
    $PubSubPath = $Subscription;        
    try { 
        $CurrentBroker = $PubSubBroker;
        
        $subscriptions = $CurrentBroker.Queues[$PubSubPath];
        if ($subscriptions -and $SubscriptionId -ge 0 -and $SubscriptionId -lt $subscriptions.Count) {
            # Remove the subscription with the specified ID
            $subscriptions[$SubscriptionId] = $null
        } else {
            Write-Error "Subscription not found for ID: $SubscriptionId";
            return;
        }
    }catch { 
        Write-Error "Failed to remove subscription: $_"; 
        return; 
    }
}
function New-Published($Publisher, $Data, $PubSubBroker = $GlobalPOSHPubSubBroker) {
    $PubSubPath = $Publisher;        
    if (-Not (Test-PubSubPath $PubSubPath)) { 
        Write-Error "Invalid Publisher path format."; 
        return; 
    }
    try {
        $CurrentBroker = $PubSubBroker;

        $subscriptions = $CurrentBroker.Queues[$PubSubPath];
        if (-Not $subscriptions) {
            Write-Error "No subscribers found for publisher: $PubSubPath"; 
            return;
        }
        foreach($sub in $subscriptions) {            
            try {
                if (-Not $Data) { $Data = @{}; }
                $sub.GetType() | Out-Null;
                $sub.ScriptBlock.Invoke($Data);
            }
            catch {
                Write-Error "Subscription ScriptBlock does not exist, Subscription may have been removed: $_"; 
                return;
            }
        }
    }
    catch {
        Write-Error "Failed to publish data: $_";
    }
}