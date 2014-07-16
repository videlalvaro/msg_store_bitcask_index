-module(msg_store_bitcask_index).

-behaviour(rabbit_msg_store_index).

-rabbit_boot_step({msg_store_bitcask_index,
                   [{description, "Bitcask Index for rabbit_msg_store"},
                    {mfa,         {application, set_env,
                                   [rabbit, msg_store_index_module, ?MODULE]}},
                    {enables,     recovery}]}).

-export([new/1, recover/1,
         lookup/2, insert/2, update/2, update_fields/3, delete/2,
         delete_object/2, delete_by_file/2, terminate/1]).

-include_lib("rabbit_common/include/rabbit_msg_store.hrl").

-define(BITCASK_DIR, "bitcask_data").

new(Dir) ->
    Path = get_path(Dir),
    {ok, Ref} = init(Path),
    Ref.

recover(Dir) ->
    Path = get_path(Dir),
    {ok, Ref} = init(Path),
    {ok, Ref}.

get_path(Dir) ->
  filename:join(Dir, ?BITCASK_DIR).

init(Dir) ->
  case bitcask:open(Dir, [read_write]) of
      {error, Error}
          -> {error, Error};
      Ref
          -> {ok, Ref}
  end.

%% Key is MsgId which is binary already
lookup(Key, Bitcask) ->
    case bitcask:get(Bitcask, Key) of
      {ok, Value} -> #msg_location{} = binary_to_term(Value);
      _ -> not_found
    end.

insert(Obj = #msg_location{ msg_id = MsgId }, Bitcask) ->
    ok = bitcask:put(Bitcask, MsgId, term_to_binary(Obj)),
    ok.

update(Obj = #msg_location{ msg_id = MsgId }, Bitcask) ->
    ok = bitcask:put(Bitcask, MsgId, term_to_binary(Obj)),
    ok.

update_fun({Position, NewValue}, ObjAcc) ->
    setelement(Position, ObjAcc, NewValue).

update_fields(Key, Updates, Bitcask) ->
    case bitcask:get(Bitcask, Key) of
      {ok, Value} ->
          Obj = #msg_location{} = binary_to_term(Value),
          NewObj =
              case is_list(Updates) of
                    true  -> lists:foldl(fun update_fun/2, Obj, Updates);
                    false -> update_fun(Updates, Obj)
              end,
          ok = bitcask:put(Bitcask, Key, term_to_binary(NewObj)),
          ok;
      _ -> not_found
    end,
    ok.

delete(Key, Bitcask) ->
    ok = bitcask:delete(Bitcask, Key),
    ok.

delete_object(Obj = #msg_location{ msg_id = MsgId }, Bitcask) ->
    case bitcask:get(Bitcask, MsgId) of
      {ok, Value} ->
          case Obj =:= binary_to_term(Value) of
              true ->
                  ok = bitcask:delete(Bitcask, MsgId),
                  ok;
              _    ->
                not_found
          end;
      _ -> not_found
    end.

delete_by_file(File, Bitcask) ->
    ok = bitcask:fold(Bitcask,
            fun(Key, Obj, Acc) ->
                case (binary_to_term(Obj))#msg_location.file of
                    File ->
                        bitcask:delete(Bitcask, Key),
                        Acc;
                    _    ->
                        Acc
                    end
                end, ok),
    ok.

terminate(Bitcask) ->
    ok = bitcask:close(Bitcask),
    ok.
