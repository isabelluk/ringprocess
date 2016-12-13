-module(process).
-export([start/2,create_node/2,create_node/3,loop/2]).

start(N,R) ->
    io:format("Spawning ~w nodes!~n",[N]),
    spawn(process,create_node,[N,R]). 

create_node(N,R) ->
    io:format("Creating node ~w (~w)~n", [N,self()]),
    create_node(N,self(),R).

create_node(1,NextPid,R) ->
	NextPid ! token,
    register(head, self()),
    statistics(wall_clock),
    loop(NextPid,R);
create_node(N,NextPid,R) ->
    PrevPid = spawn_link(process, loop, [NextPid,R]),
    create_node(N - 1, PrevPid,R).

timer() ->
    {_, Time} = statistics(wall_clock),
    io:fwrite("Total time is ~w ms~n",[Time]).

loop(NextPid,R) ->
    case R of
        R when R > 0 ->
            NextPid ! token,
            receive
                token ->
        	       io:fwrite("(~w) passing it to ~p~n",[R,NextPid]),
                   loop(NextPid,R-1)
            end;
        0 ->
            NextPid ! stop,
            receive
                stop ->
                    NextPid ! stop
            end
    end,
    timer().