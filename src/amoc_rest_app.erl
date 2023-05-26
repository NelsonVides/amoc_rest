-module(amoc_rest_app).

-behaviour(application).

-export([start/2, stop/1]).

-spec start(application:start_type(), term()) -> {ok, pid()}.
start(_StartType, _StartArgs) ->
    LogicHandler = amoc_rest_api_logic_handler,
    Port = amoc_config_env:get(api_port, 4000),
    ServerParams = #{ip => {0, 0, 0, 0}, port => Port, net_opts => [],
                     logic_handler => LogicHandler},
    amoc_rest_server:start(http_server, ServerParams).

-spec stop(term()) -> ok.
stop(_State) ->
    amoc_rest_server:stop(http_server).
