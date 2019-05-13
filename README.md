# Blast

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Getting started

1. Visit the lobby [here](http://localhost:4000).

2. Click on "Launch Game"

This creates a new game on the server. You can now copy and share the game link with friends or you can join the game.

Blast uses HTML Session Storage so you can have a player per browser tab that you have open. This makes it easy to test during local development.

## Game controls

Rotate left: left cursor key
Rotate right: right cursor key

Fire booster: up cursor key
Fire weapon: spacebar

## Scoring

Basic scoring is implemented but not displayed anywhere.

- +5 points for every hit
- -5 points every time you are hit

## Spawning

At the start of the game, players are spawned as far away from the other players as possible (evenly spread out). Newly spawned players will oriented as per that player's initial orientation and position.

## Ending the game

## Ideas for the workshop

### Basic: Game link sharing

Currently it shares a relative link, e.g. `/game/FCD2`. For easy sharing it should
include the full host name (not localhost!).

Perhaps set the hostname as an env var before running the server?

### Basic: Scoring

Display live scores during the game.

To achieve this we need a place to put the scores. `lib/blast_web/live/game_live.ex` is where the rendering
takes place. It renders an SVG of the game arena and all fighters and projectiles.

Either render the scores inside the SVG using some markup like this for example:

```
<svg height="90" width="200">
  <text x="10" y="20" style="fill:red;">Several lines:
    <tspan x="10" y="45">First line.</tspan>
    <tspan x="10" y="70">Second line.</tspan>
  </text>
</svg>
```

Or render the scores in one of the gutters to the left or right of the arena.

#### The score data

The scores can be obtained from the GameState `lib/blast/game_state.ex`.

The score for each fighter is in `GameState.fighters[fighter_id].score`.

Scores should be sorted highest to lowest and displayed like this:

- Player 2: 530
- Player 1: 375
- Player 3: 210
- Player 4: 175

Where each player number comes from the `id` of the Fighter struct.

### Basic: Prevent ammo from running out

Find where the book keeping is done that keeps track of the ammo of the Fighter
and change the code so that it never runs out.

### Intermediate: lower the fire repeat rate

The guns will fire for every animation frame in which the `FighterControls.guns` are set to `:firing`.

This makes the game less fun IMHO.

The FighterControls module is where user input is translate to an effect in the game.

`FighterControls.fire_guns/2` is where the action happens. In order to perform rate limiting
there will need to be a way to know when a projectile was last fired by a fighter and there
will need to be an additional argument passed into `fire_guns` representing the current time.

I suggest that time be represented as a frame count, and when the fighter last fired could be
represented as the number of the frame when the guns were last fired. Store this on the Fighter
module.

### Basic: Flash the fighter white when it is hit

This is a classic game mechanic to indicate damage taken. Flash the fighter white for a few seconds.

This could be implemented by storing a `last_hit_time` (as the number of the animation frame when the
hit occurred).

Fighters are rendered in `lib/blast/fighter_renderer.ex`. If the current animation frame is passed
as a parameter to the renderers then the fighter colour can be set to white when the difference between
the current animation frame number and the `last_hit_time`.

### Intermediate: Implement the endgame condition

The game ends when a player reaches 50 (or whatever) points. The winner is the player with the most points.

Imagine that the game terminates and announces the winner.

To do this we'd need to assess the state of the game state on every server frame. The GameState module is
here `lib/blast/game_state.ex`. Inside `GameState.process_events/3` there is a pipeline of function calls
that apply for every server frame.

I suggest adding a `check_game_over/1` function that sets a `game_over` flag on the GameState when the end
game condition is satisfied, then update the rendering in `GameLive` to announce the winner.

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

### Intermediate to Advanced: Add some solid, deflecting features to the arena

These will provide cover for fighters.

Circles will be easiest to implement because collisions with arbitrary shapes have not yet been implemented.

- update PhysicsObject to add a 'static' field. When set to true it represents an immovable object.
- create a Blast.StaticObject module. This will have an `object` field
- update GameState to add a `static_objects` field.
- Implement the render protocol for Blast.StaticObject
- Handle collisions with of fighters and projectiles with the static object. The static object itself will remain
  unaffected by the collision.

### Intermediate: multiplayer on same laptop & browser window

- On the view rendered by Blast.GameLive, add a button that when clicked adds another player
- Define an extra set of key bindings to control the additional player
- Note: currently players are identifie by a player_id in the session; this will need need to change
  in order to to be able identify multiple players from one browser.

### Intermediate: add on-screen controls for mobile usage

- On the GameLive view, add some control buttons to the screen either side of the rendered game arena.
- Add new `handle_player_event` function heads to trap the button events.
- Use a CSS media query to ensure that these buttons are only rendered on mobile devices in landscape mode.

### Intermediate: add spectator mode (view game without creating a fighter)

- add a new route in the router (something like `/spectate/#{game_id}`).
- clicking on this link will render the game arena but will not create a new player
- spectating people will have no FighterControls in the GameState so you will need to ensure
  that attempting to update FighterControls will not crash for spectating players if they press a key

### Advanced: homing missile

The basic vector maths is there but you'd need to calculate a force vector between the
missile and the nearest fighter using something like the inverse-square law to calculate
the strength of the force vector attracting the homing missile to its target.

### Advanced: zoom the viewport to fit the combined bounding box of all players

This would be a really cool effect that zooms in and out of the action during gameplay.
