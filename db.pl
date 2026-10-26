:- use_module(library(clpz)).
%:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(dif)).

% TODO: use deck to count cards, count duplicates
% TODO: add corrupted alignment
% TODO: Evil != Lying
% TODO: Add interactive cards
% TODO: add roles

types([villager, outcast, minion, demon]).
alignments([good, evil]).

isGood(Pos, AlignmentList) :- nth0(Pos, AlignmentList, good).
isEvil(Pos, AlignmentList) :- nth0(Pos, AlignmentList, evil).
notGood(Pos, AlignmentList) :- nth0(Pos, AlignmentList, A), dif(A, good), alignments(AllAlignments), delete(AllAlignments, good, NonGoodAlignments),member(A, NonGoodAlignments).
notEvil(Pos, AlignmentList) :- nth0(Pos, AlignmentList, A), dif(A, evil), alignments(AllAlignments), delete(AllAlignments, evil, NonEvilAlignments),member(A, NonEvilAlignments).

count_good([],0).
count_good([good|T],N) :- count_good(T,N1), N is N1 + 1.
count_good([X|T], N) :- X \= good, count_good(T,N).

count_evil([],0).
count_evil([evil|T],N) :- count_evil(T,N1), N is N1 + 1.
count_evil([X|T], N) :- X \= evil, count_evil(T,N).

% confessor is dizzy if not good 
confessorClue([AlignmentList, Pos, notdizzy]) :- isGood(Pos, AlignmentList). 
confessorClue([AlignmentList, Pos, dizzy]) :- isEvil(Pos, AlignmentList). 

% gemcrafter gives position of good card, or bad card if evil
gemcrafterClue([AlignmentList, Pos, GoodPos]) :- isGood(Pos, AlignmentList), isGood(GoodPos, AlignmentList). 
gemcrafterClue([AlignmentList, Pos, GoodPos]) :- isEvil(Pos, AlignmentList), isEvil(GoodPos, AlignmentList). 

% lover counts the adjacent evils
loverClue_(AlignmentList, Pos, AdjEvils) :-
    alignments(Alignments),
    maplist(member, [A,B], [Alignments, Alignments]),
    length(AlignmentList, NCards),
    Above is (Pos+1) mod NCards,
    nth0(Above, AlignmentList, A),
    Below is (Pos-1) mod NCards,
    nth0(Below, AlignmentList, B),
    count_evil([A,B], AdjEvils).
loverClue([AlignmentList, Pos, AdjEvils]) :- 
    isGood(Pos, AlignmentList),
    loverClue_(AlignmentList, Pos, AdjEvils).
loverClue([AlignmentList, Pos, AdjEvils]) :-
    isEvil(Pos, AlignmentList),
    loverClue_(AlignmentList, Pos, EvilCount),
    dif(EvilCount, AdjEvils).

% Rotate through, checking for closest evil in direction Dir
enlightenedClueRot(AlignmentList, NCards, Pos, Start, 1, Dir) :-
    TestPos #= (Pos + (Start * Dir)) mod NCards,
    isEvil(TestPos, AlignmentList).
enlightenedClueRot(AlignmentList, NCards, Pos, Start, N, Dir) :- 
    member(Dir, [-1,1]),
    Start #> 0,
    Start #< NCards,
    Start1 #= Start + 1,
    enlightenedClueRot(AlignmentList, NCards, Pos, Start1, N1, Dir),
    N is N1 + 1.
% enlightened clue is -1,0,or 1
enlightenedClueDir(1, CW, CCW) :- CW #< CCW.
enlightenedClueDir(0, CW, CCW) :- CW #= CCW.
enlightenedClueDir(-1, CW, CCW) :- CW #> CCW.
% check both directions
enlightenedClueCk(AlignmentList, Pos, Rot) :- 
    length(AlignmentList, NCards), 
    enlightenedClueRot(AlignmentList, NCards, Pos, 1, CW, 1), 
    enlightenedClueRot(AlignmentList, NCards, Pos, 1, CCW, -1),
    enlightenedClueDir(Rot, CW, CCW).
% clue is T/F based on alignment
enlightenedClue([AlignmentList, Pos, Rot]) :- 
    isGood(Pos, AlignmentList),
    enlightenedClueCk(AlignmentList, Pos, Rot).
enlightenedClue([AlignmentList, Pos, Rot]) :- 
    isEvil(Pos, AlignmentList),
    enlightenedClueCk(AlignmentList, Pos, NRot),
    dif(NRot, Rot).

% TODO: include role in this clue, same as gemcrafter currently
mediumClue([AlignmentList, Pos, GoodPos]) :- isGood(Pos, AlignmentList), isGood(GoodPos, AlignmentList). 
mediumClue([AlignmentList, Pos, GoodPos]) :- isEvil(Pos, AlignmentList), isEvil(GoodPos, AlignmentList). 

hunterClue_(AlignmentList, Pos, NCards, Distance, Distance, Dir) :-
    TestPos #= (Pos + (Distance * Dir)) mod NCards,
    isEvil(TestPos, AlignmentList).
hunterClue_(AlignmentList, Pos, NCards, Distance, Steps, Dir) :-
    member(Dir, [-1,1]),
    Steps #< Distance,
    TestPos #= (Pos + (Steps * Dir)) mod NCards,
    isGood(TestPos, AlignmentList),
    NextStep #= Steps + 1,
    hunterClue_(AlignmentList, Pos, NCards, Distance, NextStep, Dir).
hunterClue([AlignmentList, Pos, Distance]) :- 
    isGood(Pos, AlignmentList),
    length(AlignmentList, NCards),
    (
        hunterClue_(AlignmentList, Pos, NCards, Distance, 1, 1);
        hunterClue_(AlignmentList, Pos, NCards, Distance, 1, -1)
    ).
hunterClue([AlignmentList, Pos, Distance]) :- 
    isEvil(Pos, AlignmentList),
    length(AlignmentList, NCards),
    \+ (
        hunterClue_(AlignmentList, Pos, NCards, Distance, 1, 1);
        hunterClue_(AlignmentList, Pos, NCards, Distance, 1, -1)
    ).

inDeck([], _).
inDeck([A|As], Deck) :-
        member(A, Deck),
        inDeck(As, Deck).

cluesCk([], _).
cluesCk([A|As], AlignmentList) :-
    A = [F|Args],
    Newargs = [AlignmentList|Args],
    call(F, Newargs),
    cluesCk(As, AlignmentList).

/*
 Deck is a list of the cards in the deck
 Sums is [V, O, M, D] where each variable is the number of villagers, outcasts, minions, and demons
 AlignmentList is the good/evil of each card
 Clues is a list of clues
*/
db_solver(Sums, Clues, AlignmentList) :- 
    Sums = [V,O,_,_],
    sum_list(Sums, SumsLen),  % get the number of cards played
    length(AlignmentList, SumsLen),

    cluesCk(Clues, AlignmentList),

    sum_list([V,O], NGood),     
    count_good(AlignmentList, NGood) % make sure the number of good cards matches (evil count is implied)
    .

/*
 Problem definition before query
*/

sums([5,0,1,0]).
clues([
[gemcrafterClue, 0, 3],
[loverClue, 1, 1],
[confessorClue, 2, notdizzy],
[hunterClue, 3, 2],
[mediumClue, 4, 0],
[enlightenedClue, 5, 1]
]).


/*
?- sums(Sums), clues(Clues),
db_solver(Sums,Clues,AlignmentList).
*/
