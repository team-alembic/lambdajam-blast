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

Rotate left: left cursor key
Rotate right: right cursor key

Fire booster: up cursor key
Fire weapon: spacebar

## Scoring

+1 point for every opponent you hit.
+5 points for every kill.
-1 point for every hit by an opponent on you
-5 points every time you are killed

## Spawning

At the start of the game, players are spawned as far away from the other players as possible (evenly spread out). Newly spawned players will oriented as per that player's initial orientation and position.

## Ending the game

## Ideas for the workshop

### Basic: Game link sharing

Currently it shares a relative link, e.g. `/game/FCD2`. For easy sharing it should
include the full host name (not localhost!).

Perhaps set the hostname as an env var before running the server?

### Basic: Improve rendering performance by rounding precision of vertex data

This will reduce the size of the DOM diff sent from the server to the browser.

### Basic: Scoring

Implement the scoring rules above and display live scores during the game.

Sort the scoreboard according to high scores.

### Basic: Recharge ammo when it runs out

Or, make it never run out. But right now the repeat rate is too high and it does
eventually run out permanently!

### Basic: Flash the fighter white when it is hit

This is a classic game mechanic to indicate damage taken. Flash the fighter white for a few seconds.

### Basic: Render the projectiles as solid circles (reduce amount of rendered SVG data

This would improve rendering performance. Currently an SVG polygon element and its vertices
are rendered for every projectile. A circle has a positition and a size and that's it.

### Intermediate: Implement the endgame condition

The game ends when a player reaches 50 points or the game owner stops the game. The winner
is the player with the most points.

### Intermediate: Add sound effects using the HTML5 audio element

Pre-canned sound effects are in the repo in `assets/static/sfx` and are served from `$HOST/sfx/file.wav`.

Details here:

https://developer.mozilla.org/en-US/docs/Web/HTML/Element/audio

The audio tags could be rendered by GameLive before or after the svg element. You'll need have some
book-keeping state to know when to clean up tags that have finished playing.

### Intermediate: Animate some thruster exhaust

Render an exhaust plume out of the back of the fighter. Start simple - a non animated static
triangle representing a flame would suffice. Animate it for bonus points. Get creative - you
could offload the animation to a CSS animation of an SVG shape and just toggle a class on an
element. That way keeping track of a temporal animation on the server and all of the book
keeping that it would entail can be avoided.

### Intermediate: Powerup items

Spawn power up items into the game. On collision they are picked up by the colliding Fighter.

- Shields

Add a field to Fighter (shields :on/:off)
Fighter becomes immune to damage for a few seconds.
Render an SVG circle around the fighter when it has shields on.

Simpler option: every 20 seconds of play, pick a random fighter that gets shields as a power up.

- Bigger guns / higher fire rate

Add a field to Fighter (big_guns :on/:off)
That Fighter's guns either get a higher firing rate or do more damage on a hit.

Simpler option: every 20 seconds of play, pick a random fighter that gets bigger guns as a power up.

### Intermediate: Rate limit firing of guns

Currently a projectile fires for every animation frame that the when fighter controls 'guns' setting is set to firing.

We should prevent the weapons firing for say more frequently than every 10th of a second.

This would require some book keeping to record on the Fighter the last time that the guns were actually fired.

The GameState should track the number of animated frames and pass that through to the FighterControls gun firing logic.

### Advanced: homing missile

The basic vector maths is there but you'd need to calculate a force vector between the missile and the nearest fighter.

### Advanced: zoom the viewport to fit the combined bounding box of all players

This would be a really cool effect that zooms in and out of the action during gameplay.
