-- Position of the first brick
ANCHOR = {x = 2, y = 0.2}

States = {
    BallOnPaddle = 1,
    GameOver = 2,
    Pause = 3,
    BallLaunched = 4,
}

_state = States.Pause

function Local.Init()
    _ball = Engine.Scene:createGameObject("Ball", "ball"){}
    _paddle = Engine.Scene:createGameObject("Paddle", "paddle"){position = {x = 0.5, y = 0.8, unit = "ViewPercentage"}}
    Object.ballToPaddle()
    -- TESTING
    for i = 0, 19 do
        for j = 0, 9 do
            Engine.Scene:createGameObject("Block", "block_"..i.."_"..j){position = {x = ANCHOR.x + 0.6*i, y = ANCHOR.y + 0.3*j}}
        end
    end
end

function Object:ballToPaddle()
    _paddle:getSceneNode():addChild(_ball:getSceneNode())
    local paddlePos = _paddle:getPos("Top")
    _ball:stop()
    _ball:setAngle(60)
    _ball:setPos(paddlePos.x, paddlePos.y - 0.0001, "SceneUnits", "Bottom")
    _state = States.BallOnPaddle
end

function Object:launchBall()
    _paddle:getSceneNode():removeChild(_ball:getSceneNode())
    _ball:launch()
    _state = States.BallLaunched
end

function Event.Actions.LeftClick()
    if _state == States.BallOnPaddle then Object:launchBall() end
end