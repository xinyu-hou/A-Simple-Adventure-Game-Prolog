/*
  This is a little adventure game.  There are four
  entities: you, a treasure, a key, and an ogre.  There are 
  seven places: a valley, a path, a cliff, a fork, a maze, a
  gate, and a mountaintop.  Your goal is to get the treasure
  without being killed first.
  New features added: (1) User can go backward in this game.
  (2) User can win the game faster by using the command: pass 
  at maze(1). If the user tries to use pass at any other 
  locations, a message will show up, telling the user to get 
  to the right location first.
*/

/*
  Playthrough 1:
  f
  --forward-----
  You are on a path, with ravines on both sides.
  You have nothing in your pocket.
  Next move --
  f
  --forward-----
  You are at a fork in the path.
  You have nothing in your pocket.
  Next move --
  l
  --left-----
  You are in a maze of twisty trails, all alike.
  You have nothing in your pocket.
  A sliver key is laying on the ground.
  What is it for?
  Next move --
  l
  --left-----
  You are in a maze of twisty trails, all alike.
  You have nothing in your pocket.
  A message appears in the sky. It says
  Use pass to pass, or not.
  Next move --
  pass
  Okay so you take the treasure and skip all the fun.
  Maybe try the game again?
  Thanks for playing.
*/

/*
  Playthrough 2:
  f
  --forward-----
  You are on a path, with ravines on both sides.
  You have nothing in your pocket.
  Next move --
  f
  --forward-----
  You are at a fork in the path.
  You have nothing in your pocket.
  Next move --
  l
  --left-----
  You are in a maze of twisty trails, all alike.
  You have nothing in your pocket.
  A sliver key is laying on the ground.
  What is it for?
  Next move --
  take(key)
  Now you have it.
  Next move --
  b
  --backward-----
  You are at a fork in the path.
  Item(s) in pocket: key
  Next move --
  r
  --right-----
  An iron gate stands in front of you. It cannot be opened by force.
  Item(s) in pocket: key
  You unlock the gate with your silver key.
  Next move --
  f
  --forward-----
  You are walking through the gate
  Item(s) in pocket: key
  Walk through the gate with the key in hand may not be a good idea,
  You have been killed by lightning.
  Thanks for playing.
*/

/* Allow asserts and retracts for the predicate at */
:- dynamic at/2.

/*
  First, text descriptions of all the places in 
  the game.
*/
description(valley,
  'You are in a pleasant valley, with a trail ahead.').
description(path,
  'You are on a path, with ravines on both sides.').
description(cliff,
  'You are teetering on the edge of a cliff.').
description(fork,
  'You are at a fork in the path.').
description(maze(_),
  'You are in a maze of twisty trails, all alike.').
description(mountaintop,
  'You are on the mountaintop.').
description(gate,
  'An iron gate stands in front of you. It cannot be opened by force.').
description(open_gate,
  'You are walking through the gate').

/*
  report prints the description of your current
  location.
*/
report :-
  at(Object,possessed),
  at(you,X),
  description(X,Y),
  write(Y),nl,
  write('Item(s) in pocket: '),
  write(Object),nl,
  !.
report :-
  at(you,X),
  description(X,Y),
  write(Y),nl,
  write('You have nothing in your pocket.'),
  nl.

/*
  These connect predicates establish the map.
  The meaning of connect(X,Dir,Y) is that if you
  are at X and you move in direction Dir, you
  get to Y.  Recognized directions are
  forward, right, and left.
*/
connect(valley,forward,path).

connect(path,backward,valley).
connect(path,right,cliff).
connect(path,left,cliff).
connect(path,forward,fork).

connect(fork,backward,path).
connect(fork,left,maze(0)).
connect(fork,right,gate).

connect(maze(0),backward,fork).
connect(maze(0),left,maze(1)).
connect(maze(0),right,maze(3)).

connect(gate,backward,fork).
connect(gate,forward,gate).

connect(gate2,forward,open_gate).

connect(open_gate,forward,mountaintop).
connect(open_gate,backward,gate2).

connect(maze(1),left,maze(0)).
connect(maze(1),right,maze(2)).
connect(maze(2),left,fork).
connect(maze(2),right,maze(0)).
connect(maze(3),left,maze(0)).
connect(maze(3),right,maze(3)).

/* shortcuts for move */

move(f) :- move(forward).
move(b) :- move(backward).
move(l) :- move(left).
move(r) :- move(right).
move(take(Object)) :- pickup(Object).
move(drop(Object)) :- getrid(Object).
move(pass) :- winanyway.

/*
  move(Dir) moves you in direction Dir, then
  prints the description of your new location.
*/
move(Dir) :-
  write('--'),write(Dir),write('-----'),nl,
  at(you,Loc),
  connect(Loc,Dir,Next),
  retract(at(you,Loc)),
  assert(at(you,Next)),
  report,
  !.
/*
  But if the argument was not a legal direction,
  print an error message and don't move.
*/
move(_) :-
  write('That is not a legal move.'),nl,
  report.

/*
  Object pick up implementation.
*/
pickup(Object) :-
    at(Object,possessed),
    write('The object is in your hand already!'),nl,
    !.
pickup(Object) :-
    at(you,Loc),
    at(Object,Loc),
    retract(at(Object,Loc)),
    assert(at(Object,possessed)),
    write('Now you have it.'),nl,
    !.
pickup(_) :-
    write('Hmm...I wonder what you are looking for.'),nl,
    write('There is nothing for you to pick up.'),nl,
    report.

/*
  Object drop implementation.
*/
getrid(Object) :-
    at(Object,possessed),
    at(you,Loc),
    retract(at(Object,possessed)),
    assert(at(Object,Loc)),
    write('Now you get rid of it.'),nl,
    !.
getrid(_) :-
    write('How can you drop if you have nothing.'),nl.

/*
  Just win the game implementation.
  If user uses pass at maze(1), 
  one wins the game.
*/
winanyway :-
    at(pass_sign,Loc),
    at(you,Loc),
    write('Okay so you take the treasure and skip all the fun.'),nl,
    write('Maybe try the game again?'),nl,
    retract(at(you,Loc)),
    assert(at(you,done)),
    !.
winanyway :-
    write('Trying to cheat now?'),nl,
    write('At least get to that location.'),nl,
    report.

/*
  If you and the ogre are at the same place, 
  it kills you.
*/
ogre :-
  at(ogre,Loc),
  at(you,Loc),
  write('An ogre sucks your brain out through'),nl,
  write('your eye sockets, and you die.'),nl,
  retract(at(you,Loc)),
  assert(at(you,done)),
  !.
/*
  But if you and the ogre are not in the same place,
  nothing happens.
*/
ogre.

/*
  If you and the treasure are at the same place, you
  win.
*/
treasure :-
  at(treasure,Loc),
  at(you,Loc),
  write('There is a treasure here.'),nl,
  write('Congratulations, you win!'),nl,
  retract(at(you,Loc)),
  assert(at(you,done)),
  !.
/*
  But if you and the treasure are not in the same
  place, nothing happens.
*/
treasure.

/*
  If you and the key are at the same place, 
  you get a notification.
*/
key :-
    at(key,Loc),
    at(you,Loc),
    write('A sliver key is laying on the ground.'),nl,
    write('What is it for?'),nl,
    !.
/*
  But if you and the key are not at the same place, 
  nothing happens.
*/
key.

/*
  If you and the pass are at the same place,
  you get a notification.
*/
pass_sign :-
    at(pass_sign,Loc),
    at(you,Loc),
    write('A message appears in the sky. It says'),nl,
    write('Use pass to pass, or not.'),nl,
    !.
/*
  But if you and the key are not at the same place, 
  nothing happens.
*/
pass_sign.

/*
  If you are at the cliff, you fall off and die.
*/
cliff :-
  at(you,cliff),
  write('You fall off and die.'),nl,
  retract(at(you,cliff)),
  assert(at(you,done)),
  !.
/*
  But if you are not at the cliff nothing happens.
*/
cliff.

/*
  If you are at the gate with the key,
  you open the gate.
*/
gate :- 
    at(you,gate),
    at(key,possessed),
    retract(at(you,gate)),
    assert(at(you,gate2)),
    write('You unlock the gate with your silver key.'),nl,
    !.
/*
  But if you are not at the gate, nothing happens.
*/
gate.

/*
  If you walk through the gate with the key,
  you are killed by lightning.
*/
gate2 :-
    at(you,open_gate),
    at(key,possessed),
    write('Walk through the gate with the key in hand may not be a good idea,'),nl,
    write('You have been killed by lightning.'),nl,
    retract(at(you,open_gate)),
    assert(at(you,done)),
    !.
/*
  If you walk through the gate without the key,
  nothing happens.
*/
gate2.

/*
  Main loop.  Stop if player won or lost.
*/
main :- 
  at(you,done),
  write('Thanks for playing.'),nl,
  !.
/*
  Main loop.  Not done, so get a move from the user
  and call it.  Then run all our special behaviors.  
  Then repeat.
*/
main :-
  write('\nNext move -- '),
  read(Move),
  call(move(Move)),
  ogre,
  treasure,
  cliff,
  gate,
  gate2,
  key,
  pass_sign,
  main.

/*
  This is the starting point for the game.  We
  assert the initial conditions, print an initial
  report, then start the main loop.
*/    
go :-
  retractall(at(_,_)), % clean up from previous runs
  assert(at(you,valley)),
  assert(at(ogre,maze(3))),
  assert(at(treasure,mountaintop)),
  assert(at(key,maze(0))),
  assert(at(pass_sign,maze(1))),
  write('This is an adventure game.'),nl,
  write('Legal moves are (l)eft, (r)ight, (f)orward, or (b)ackward.'),nl,
  write('For example, use f to nagivate forward.'),nl,
  write('To pick up an item, use take(Object).'),nl,
  write('To drop an item, use drop(Object).'),nl,
  write('For example, use take(map) to pick up a map.'),nl,
  write('End each move with a period.'),nl,
  report,
  main.
