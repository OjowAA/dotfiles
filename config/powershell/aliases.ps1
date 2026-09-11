function Grep-Object {
    param(
        [Parameter(Position=0)]
        [string]$Pattern,

        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        $InputObject | Where-Object {
            $_.PSObject.Properties |
                Where-Object { $_.Name -match 'name' -and $_.Value -match $Pattern }
        }
    }
}

function Grep {
    param(
        [Parameter(Position=0)]
        [string]$Pattern,

        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        $InputObject | Out-String -Stream | Select-String -Pattern $Pattern
    }
}

function Head { param([int]$Count = 10) $input | Select-Object -First $Count }
function Tail { param([int]$Count = 10) $input | Select-Object -Last $Count }
function Skip { param([int]$Count) $input | Select-Object -Skip $Count }

Set-Alias go Grep-Object
Set-Alias so Select-Object
Set-Alias wo Where-Object