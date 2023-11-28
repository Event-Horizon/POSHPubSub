Import-Module .\POSHPubSub.ps1
function Start-POSHPubSubExample(){
    # Using Global Broker
    $AppLogSub=New-Subscription "application\logging" {Param($Data) Write-Output $Data}
    $AppErrSub=New-Subscription "application\errors" {Param($Data) Write-Output $Data}
    New-Published "application\logging" "Log: Test1"
    New-Published "application\errors" "Error: Test2"

    # Using Custom Broker
    $AppBroker=New-PubSubBroker "MyApplicationBroker"
    $AppLogSub=New-Subscription "application\logging" {Param($Data) Write-Output $Data} $AppBroker
    $AppErrSub=New-Subscription "application\errors" {Param($Data) Write-Output $Data} $AppBroker
    New-Published "application\logging" "Log: Test3" $AppBroker
    New-Published "application\errors" "Error: Test4" $AppBroker
}
Start-POSHPubSubExample