type Inventory = {
    [string] : {
        Name: string,
        Type: string,
        Amount: number | nil,
    }
}

return {
    ProfileTemplate = {
        Inventory = {

            ["Apple"] = {
                Name="Apple",
                Id="apple",
                Type="Consumable",
                Amount=1,
            }

        },

    },
    ProfileKey = "DEADLYSINS"
}