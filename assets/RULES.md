# Game Objective
The first player to play all cards in their hand wins the game. For the remaining players, a ranking is assigned based on the remaining cards in their hand based on the scoring system below.
# Cards
## Number (0-9)
These cards may be played on top of any card with the same number or color. 

## Draw 2
These cards may be played on top of another `Draw 2` or when the color matches the previous card. When played, the next player must draw 2 cards, then end their turn.

## Skip
These cards may be played on top of another `Skip` or when the color matches the previous card. When played, the next player is skipped and loses their turn.

## Reverse
These cards may be played on top of another `Reverse` or when the color matches the previous card. This card reverse the turn order.

## Wild 
This card may be played on top of *any* card. When played, you can select a color for the next player.

## Wild +4
This card acts the same as a `Wild` but the next player must draw 4 cards then end their turn.

# Scoring
At the end of a game each player gets 100 points plus 100 points for each player who has more
cards in their hand then them. For example, imagine a game where player B has used all their cards...

* A has 3 cards
* B has 0 cards
* C has 7 cards

As a result, B is given 300 points, A is given 200, and C is given 100 points. At this point,
each player loses points based on each card in their hand. Since B has no cards, they will
still have 300 points, but A and C will have less.

* **Number (0-9)** - Subtract the card's face value
* **Draw 2**, **Skip**, and **Reverse** - Subtract 10
* **Wild** and **Wild +4** - Subtract 15

Since we don't know what cards A and C have, lets pretend that A now has 180 points and C has 13.
Players can not lose less than 100 points from card subtractions, so the lowest A could drop would be
to 100 points.

Finally each player's score is divided by the number of players in the game, this ensures that
each player has a final score of 1 to 100 (regardless of number of players in the game), the winner will always have 100 and others will have less.

The final score of the game is...

* B has 100 points
* A has 60 points
* C has 4 points.

As you can see, player C is pretty terrible at this game. They are still, however, real cool.

## Notes about League Scoring
The scoring system is designed to mitigate the difference in scoring when
different numbers of players are playing, however it's still not perfect
so if you care deeply about league ranking, you should play all games with
the same number of players.