%%%-------------------------------------------------------------------
%%% @author Ruslan Babayev <ruslan@babayev.com>
%%% @copyright 2009, Ruslan Babayev
%%% @doc This module maps the request URI to a path.
%%% Uses `aliases', `docroot' and `indices' environment variables.
%%% Sets `path' flag.
%%% @end
%%%-------------------------------------------------------------------
-module(http_mod_alias).
-author('ruslan@babayev.com').
-export([init/0, handle/4]).

-include("http.hrl").
-include_lib("kernel/include/file.hrl").

init() ->
    ok.

handle(_Socket, Request, Response, Flags) ->
    ReqPath = http_lib:uri_to_path(Request#http_request.uri),
    DecodedPath = http_lib:urldecode(ReqPath),
    {ok, Aliases} = application:get_env(aliases),
    {ok, DocRoot} = application:get_env(docroot),
    Path1 = abs_path(DecodedPath, Aliases, http_lib:dir(DocRoot)),
    {ok, Indices} = application:get_env(indices),
    Path2 = maybe_append_index(Path1, Indices),
    [Path3 | _] = string:tokens(Path2, "?"),
    {proceed, Response, [{path, Path3} | Flags]}.

abs_path(ReqPath, [], DocRoot) ->
    DocRoot ++ ReqPath;
abs_path(ReqPath, [{Alias, Path} | Rest], DocRoot) ->
    case string:str(ReqPath, Alias) of
	1 ->
	    http_lib:dir(Path) ++ string:substr(ReqPath, length(Alias) + 1);
	_ ->
	    abs_path(ReqPath, Rest, DocRoot)
    end.

maybe_append_index(Path, Indices) ->
    case file:read_file_info(Path) of
	{ok, FileInfo} when FileInfo#file_info.type == directory ->
	    append_index(Path, Indices);
	_ ->
	    Path
    end.

append_index(Path, []) ->
    Path;
append_index(Path, [Index | Rest]) ->
    case file:read_file_info(filename:join(Path, Index)) of
	{error, _Reason} ->
	    append_index(Path, Rest);
	_ ->
	    filename:join(Path, Index)
    end.
