# POSHPubSub

This is a project implementing a version of the PubSub pattern in POSH. The current version is Powershell 7+ compatible only.

### Prerequisites

What things you need to install the software:

```
Powershell v7+
```

### Installing

A step by step series of examples that tell you how to get a development env running

Install Powershell v7+ if you haven't already.

Download and extract this project.

Import the module:

```
Import-Module POSHPubSub.psm1
```

Create a PubSubBroker if you want to reference it later:

```
$AppBroker=New-PubSubBroker "MyApplicationBroker"
```

Create a subscriber:

```
$AppLogSub=New-Subscription "application\logging" {Param($Data) Write-Output $Data} $AppBroker
```

Create a published event:

```
New-Published "application\logging" "Log: Test1" $AppBroker
```

You should have received "Log: Test1" in your console.

## Authors

* **Event_Horizon / Event-Horizon** - *Initial work* - [Event_Horizon](https://github.com/Event_Horizon)

## License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details