# Blast

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Getting started

1. Visit the lobby [here](http://localost:4000/lobby).

2. Create a new player. You won't need any credentials and the player will be bound to your browser session.

Blast uses HTML Session Storage so you can have a player per browser tab that you have open. This makes it easy to test during local development.

3. You should now be able to see a list of games, and you're able to create your own. If you create a game, your player then owns that game and control when it starts. Players can only join a game before it starts. Only the owner can start the game.

4. Optionally, players can spectate a game. You can join a game as a spectator even when the game is in progress.

## Game controls

Rotate anti-right: left cursor key or `h`.
Rotate right: right cursor key or `l`.

Fire booster: up cursor key or `j`
Fire weapon: spacebar or `k`

## Scoring

+1 point for every opponent you hit.
+5 points for every kill.
-1 point for every hit by an opponent on you
-5 points every time you are killed

## Spawning

At the start of the game, players are spawned as far away from the other players as possible (evenly spread out). Newly spawned players will oriented facing the centre of the arena.

Killed players are respawned as far from the other players as possible facing towards the centre of the arena.

## Ending the game

The game ends when a player reaches 50 points or the game owner stops the game. The winner is the player with the most points.
