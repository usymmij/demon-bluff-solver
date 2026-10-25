:- use_module(library(clpfd)).

% TODO: use deck to count cards, count duplicates
% TODO: add corrupted alignment
% TODO: Evil != Lying

alignments([good, evil]).

isGood(Pos, Alignment) :- nth0(Pos, Alignment, good).
isEvil(Pos, Alignment) :- nth0(Pos, Alignment, evil).
notGood(Pos, Alignment) :- nth0(Pos, Alignment, A), dif(A, good), alignments(AllAlignments), delete(AllAlignments, good, NonGoodAlignments),member(A, NonGoodAlignments).
notEvil(Pos, Alignment) :- nth0(Pos, Alignment, A), dif(A, evil), alignments(AllAlignments), delete(AllAlignments, evil, NonEvilAlignments),member(A, NonEvilAlignments).

count_good([],0).
count_good([good|T],N) :- count_good(T,N1), N is N1 + 1.
count_good([X|T], N) :- X \= good, count_good(T,N).

count_evil([],0).
count_evil([evil|T],N) :- count_evil(T,N1), N is N1 + 1.
count_evil([X|T], N) :- X \= evil, count_evil(T,N).

% confessor is dizzy if not good 
confessorClue([Alignment, Pos, notdizzy]) :- isGood(Pos, Alignment). 
confessorClue([Alignment, Pos, dizzy]) :- isEvil(Pos, Alignment). 

% gemcrafter gives position of good card, or bad card if evil
gemcrafterClue([Alignment, Pos, GoodPos]) :- isGood(Pos, Alignment), isGood(GoodPos, Alignment). 
gemcrafterClue([Alignment, Pos, GoodPos]) :- isEvil(Pos, Alignment), isEvil(GoodPos, Alignment). 

% lover counts the adjacent evils
loverClue_([Alignment, Pos, AdjEvils]) :-
    alignments(Alignments),
    maplist(member, [A,B], [Alignments, Alignments]),
    length(Alignment, NCards),
    Above is (Pos+1) mod NCards,
    nth0(Above, Alignment, A),
    Below is (Pos-1) mod NCards,
    nth0(Below, Alignment, B),
    count_evil([A,B], AdjEvils).
loverClue([Alignment, Pos, AdjEvils]) :- 
    isGood(Pos, Alignment),
    loverClue_([Alignment, Pos, AdjEvils]).
loverClue([Alignment, Pos, AdjEvils]) :-
    isEvil(Pos, Alignment),
    loverClue_([Alignment, Pos, EvilCount]),
    dif(EvilCount, AdjEvils).

n_factorial(0, 1).
n_factorial(N, F) :-
        N #> 0,
        N1 #= N - 1,
        F #= N * F1,
        n_factorial(N1, F1).

enlightenedClueRot(Alignment, NCards, Pos, Start, 1, Dir) :-
    TestPos #= (Pos + (Start * Dir)) mod NCards,
    isEvil(TestPos, Alignment).
enlightenedClueRot(Alignment, NCards, Pos, Start, N, Dir) :- 
    member(Dir, [-1,1]),
    Start #> 0,
    Start #< NCards,
    Start1 #= Start + 1,
    enlightenedClueRot(Alignment, NCards, Pos, Start1, N1, Dir),
    N is N1 + 1.
enlightenedClueDir(1, CW, CCW) :- CW #< CCW.
enlightenedClueDir(0, CW, CCW) :- CW #= CCW.
enlightenedClueDir(-1, CW, CCW) :- CW #> CCW.
enlightenedClueCk(Alignment, Pos, Rot) :- 
    length(Alignment, NCards), 
    enlightenedClueRot(Alignment, NCards, Pos, 1, CW, 1), 
    enlightenedClueRot(Alignment, NCards, Pos, 1, CCW, -1),
    enlightenedClueDir(Rot, CW, CCW).
enlightenedClue([Alignment, Pos, Rot]) :- 
    isGood(Pos, Alignment),
    enlightenedClueCk(Alignment, Pos, Rot).
enlightenedClue([Alignment, Pos, Rot]) :- 
    isEvil(Pos, Alignment);
    enlightenedClueCk(Alignment, Pos, NRot),
    dif(NRot, Rot).

inDeck([], _).
inDeck([A|As], Deck) :-
        member(A, Deck),
        inDeck(As, Deck).

cluesCk([], _).
cluesCk([A|As], Alignment) :-
    A = [F|Args],
    Newargs = [Alignment|Args],
    call(F, Newargs),
    cluesCk(As, Alignment).

/*
 Deck is a list of the cards in the deck
 Sums is [V, O, M, D] where each variable is the number of villagers, outcasts, minions, and demons
 Alignment is the good/evil of each card
 Clues is a list of clues
*/
db_solver(Sums, Clues, Alignment) :- 
    Sums = [V,O,_,_],
    sum_list(Sums, SumsLen),  % get the number of cards played
    length(Alignment, SumsLen),

    cluesCk(Clues, Alignment),

    sum_list([V,O], NGood),     
    count_good(Alignment, NGood) % make sure the number of good cards matches (evil count is implied)
    .

/*
 Problem definition before solution
*/

sums([4,0,1,0]).
clues([
[enlightenedClue, 0, 1],
[gemcrafterClue, 1, 1],
[gemcrafterClue, 2, 3],
[loverClue, 3, 0],
[confessorClue, 3, notdizzy]

]).


/*
?- sums(Sums), clues(Clues),
db_solver(Sums,Clues,Alignment).
*/
