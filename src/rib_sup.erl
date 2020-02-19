-module(rib_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, Port} = application:get_env(rib, port),
    AuthConfig = [{auth_fun, fun rib_callback:auth_fun/2}],
    CallbackArgs = [{mods, [{elli_basicauth, AuthConfig},
                            {rib_callback, []}]}],
    ElliOpts = [{callback, elli_middleware},
                {callback_args, CallbackArgs},
                {port, Port}],
    ElliSpec = {
      fancy_http,
      {elli, start_link, [ElliOpts]},
      permanent,
      5000,
      worker,
      [elli]},

    {ok, { {one_for_one, 5, 10}, [ElliSpec]} }.
