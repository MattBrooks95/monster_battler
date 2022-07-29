module Game.PlayerAction where

-- switch active monster a for inactive monster b
data Switch = Switch Int Int

data Forfeit = Forfeit

data Move = Move Int Int

data Action = ActionSwitch Switch | ActionForfeit Forfeit | ActionMove Move

-- an int that is the id of one of the users available actions
-- the game creates a list of possible actions for each player based on the game state,
-- and then their client prompts them to make their selections
data PotentialAction = PotentialAction Int Action
