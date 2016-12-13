-module(ring).
-export([start/1,create_node/1,create_node/2,loop/1]).


start(N) ->
    io:format("Spawning ~w nodes!~n",[N]),
    spawn(ring,create_node,[N]). 

create_node(N) ->
    io:format("Creating node ~w (~w)~n", [N,self()]),
    create_node(N,self()).

create_node(1,NextPid) ->
	NextPid ! token,
    loop(NextPid);
create_node(N,NextPid) ->
    PrevPid = spawn_link(ring, loop, [NextPid]),
    create_node(N - 1, PrevPid).

% stop() ->
%     head ! stop,
%     ok. 

loop(NextPid) ->
    receive
        token ->
        	io:fwrite("passing it to ~p~n",[NextPid]),
            NextPid ! token,
            loop(NextPid),
            ok
    end.