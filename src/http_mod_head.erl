%% @author Ruslan Babayev <ruslan@babayev.com>
%% @copyright 2009 Ruslan Babayev
%% @doc This module handles `HEAD' requests.
%%      Uses `file_info' flag.

-module(http_mod_head).
-author('ruslan@babayev.com').

-export([init/0, handle/4]).

-include("http.hrl").
-include_lib("kernel/include/file.hrl").

%% @doc Initializes the module.
%% @spec init() -> ok | {error, Error}
init() ->
    ok.

%% @doc Handles the Request, Response and Flags from previous modules.
%% @spec handle(Socket, Request, Response, Flags) ->
%%       #http_response{} | already_sent | {error, Error} |
%%       {proceed, Request, Response, Flags}
handle(_Socket, #http_request{method = 'HEAD'} = Request, undefined, Flags) ->
    FI = proplists:get_value(file_info, Flags),
    Size = FI#file_info.size,
    LM = http_lib:local_time_to_rfc1123(FI#file_info.mtime),
    Etag = http_lib:etag(FI),
    H1 = [{'Content-Length', Size}, {'Last-Modified', LM}, {'Etag', Etag}],
    H2  = case http_lib:mime_type(proplists:get_value(path, Flags)) of
	      undefined -> H1;
	      MimeType  -> [{'Content-Type', MimeType} | H1]
	  end,
    Response = #http_response{status = 200, headers = H2, body = <<>>},
    {proceed, Request, Response, Flags};
handle(_Socket, Request, Response, Flags) ->
    {proceed, Request, Response, Flags}.
