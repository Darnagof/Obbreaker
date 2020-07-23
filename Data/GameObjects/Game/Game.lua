function Local.Init()
    --Engine.Scene:createGameObject("Menu", "MainMenu")
    Object.startGame()
end

function Object:startGame()
    print("Start new game")
    _board = Engine.Scene:createGameObject("Board", "board")
end