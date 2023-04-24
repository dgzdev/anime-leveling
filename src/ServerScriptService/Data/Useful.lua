type Inventory = {
    [string] : {
        Name: string,
        Type: string,
        Amount: number | nil,
    }
}

return {
    --[[
        Esse é o save padrão, caso o jogador não tenha um save.
        Caso adicione alguma chave nesse objeto, será automaticamente adicionado a novos jogadores.
    ]]
    ProfileTemplate = {
        Inventory = {

            --[[
                Este é um exemplo de item.
                Id deve ser minúsculo.
                Amount só é necessário caso possa ser estocado.
            ]]
            ["Apple"] = {
                Name="Apple",
                Id="apple",
                Type="Consumable",
                Amount=1,
            }

        },

    },
    ProfileKey = "DEADLYSINS" --// Essa é a chave que será usada para salvar o perfil do jogador, caso seja trocado, os saves antigos serão perdidos.
}