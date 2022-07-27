# Monster Battler

## What it is
1. 1 player vs 1 player, 4 player free-for-all, 2 players v 2 players
2. monster battling game
3. monsters are dynamically added over time by a community voting process
4. the fun part's of the battle system are:
    1. rock-paper-scissors gameplay (will my oppenent switch this turn? defend? make a risky attack?)
    2. team composition (can I find monsters that I like and that complement eachother well?)
5. the monsters
    1. the game will start off with a mininum number of monsters necessary for basic team building (around 12???)
    2. every 2 or 3 months, there will be an aggregation of user-submitted monster designs and gameplay details, which are voted on by the community
    3. the elected Mon is eventually added to the game
6. game balance decisions, like monster additions, are made on a strict schedule of once or twice per year
    1. player opinions and usage statistics should be used in this decision
7. if the number of the dynamically added monsters grows too large, a rotation-style system that restricts the pool of tournament-viable monsters can be implemented

## What it is technically
1. a web backend in Haskell or Elixir
    1. Elixir would presumably be easier to get started with, and have better libraries for web dev
    2. Having Haskell be the server and game implementation would mean that the Haskell types and code could be used in several contexts
2. postgres db for registering user accounts
3. the server API for battling and other house keeping functions of the system are built in such way that third party clients can be made
4. will likely need to implement one browser-based client, to get started with

## Monitization
1. real-world currency can be used for cosmetic purchases
2. by extra votes for the monster addition system

## Stretch goals
1. in game currency that cannot be purchased
    1. this in game currency can be used to acquire game items (moves, monsters, cosmetics)
    2. this game currency can become the entry fee for tournaments
    3. tournament spectators can bet on match outcomes with the game currency
2. there may be some sort of mock virtual currency that is 
3. user account information, game results, currency balances are decentralized
