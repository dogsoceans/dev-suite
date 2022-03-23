::  uqbar-indexer:
::
::  Index blocks
::
::    Receive new blocks, index them,
::    and update subscribers with full blocks
::    or with hashes of interest
::
::
::    ## Scry paths
::
::    /x/block-height:
::      The current block height
::    /x/block:
::      The most recent block
::    /x/block/[@ud]:
::      The block with given block number
::    /x/hash/[@ux]:
::      Info about hash
::    /x/egg/[@ux]:
::      Info about egg (transaction) with the given hash
::    /x/id/[@ux]:
::      History of id with the given hash
::    /x/grain/[@ux]:
::      State of grain with given hash
::
::
::    ## Subscription paths (TODO)
::
::    /block:
::
::    /hash/[@ux]:
::
::    ##  Pokes
::
::    %set-chain-source:
::
::
/-  uqbar-indexer,
    res=resource,
    store=dao-group-store,
    zig=ziggurat
/+  agentio,
    dbug,
    default-agent,
    verb,
    daolib=dao,
    reslib=resource,
    smart=zig-sys-smart
::
|%
+$  card  card:agent:gall
::
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero
  $:  %0
      block-source=(unit dock)
      =blocks:uqbar-indexer
      =index:uqbar-indexer
  ==
--
::
=|  state-zero
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this            .
      uqbar-indexer-core  +>
      uic                 ~(. uqbar-indexer-core bowl)
      def                 ~(. (default-agent this %|) bowl)
  ::
  ++  on-init  `this(state [%0 *dao-groups:store ~])
  ++  on-save  !>(state)
  ++  on-load
    |=  =old=vase
    =/  old  !<(versioned-state old-vase)
    ?-  -.old
      %0  `this(state old)
    ==
  ::
  ++  on-poke  ::  on-poke:def
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  (team:title our.bowl src.bowl)
    =^  cards  state
      ?+  mark  (on-poke:def mark vase)
      ::
          %set-chain-source
        (set-chain-source:uic !<(dock vase))
      ::
      ::     %serve-update
      ::   :_  this
      ::   ?~  $=  update
      ::       %-  serve-update:uic
      ::       !<  :-  query-type:uqbar-indexer
      ::           query-payload:uqbar-index
      ::       vase
      ::     ~
      ::   update
      ::
      ==
    [cards this]
  ::
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+  path  (on-peek:def path)
        [%x %block-height ~]
      ``noun+!>(`@ud`(lent blocks))
    ::
        [%x %block ~]
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      ?:  =(0 (lent blocks))  ~
      `(rear blocks)
    ::
        [%x %block @ ~]
      =/  block-num=@ud  i.t.t.path
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      ?.  (lth block-num (lent blocks))  ~
      `(snag block-num blocks)
    ::
        [%x %hash @ ~]
    ::
        [%x %egg @ ~]
    ::
        [%x %id @ ~]
    ::
        [%x %grain @ ~]
    ::
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+  wire  (on-agent:def wire sign)
    ::
        [%chain-update ~]
      ?+  -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        ?~  wcs=watch-chain-source:uic  ~
        ~[u.wcs]
      ::
          %fact
        =+  !<(=update:uqbar-indexer q.cage.sign)
        ?>  ?=(%block -.update)
        ?>  =((lent blocks) num.block-header.update)
        =*  new-block  +.update
        ?~  blocks  `this(blocks ~[new-block])
        =/  previous-block  (rear blocks)
        ?>  .=  data-hash.block-header.previous-block
          data-hash.block-header.new-block
        ::  TODO: indexing into index goes here
        `this(blocks (snoc blocks new-block))
      ::
      ==
    ::
    ==
  ++  on-arvo  on-arvo:def
  ++  on-fail   on-fail:def
  ::
  --
::
|_  =bowl:gall
+*  io   ~(. agentio bowl)
::
++  watch-chain-source
  ^-  (unit card)
  ?~  chain-source  ~
  :-  ~
  %+  %~  watch  pass:io
  /chain-update  u.chain-source  /blocks  :: TODO: fill in actual path
::
++  leave-chain-source
  ^-  (unit card)
  ?~  chain-source  ~
  :-  ~
  %-  %~  leave  pass:io
  /chain-update  u.chain-source
::
++  set-chain-source  :: TODO: is this properly generalized?
  |=  d=dock
  ^-  (quip card _state)
  :_  state(chain-source `d)
  ?~  watch=watch-chain-source  ~
  ~[u.watch]
::
++  serve-update
  |=  [=query-type:uqbar-indexer =query-payload:uqbar-index]
  ^-  (unit update:uqbar-indexer)
  |^
  ?+  query-type  !!
      %block
    get-block
  ::
      ?(%grain %to %from %egg)
    get-from-index
  ::
  ==
  ::
  ++  get-block
    ^-  (unit update:uqbar-indexer)
    ?>  ?=(@ud query-payload)
    ?>  (lth query-payload (lent blocks))
    `[%block (snag query-payload blocks)]
  ::
  ++  get-chunk-update
    ^-  (unit update:uqbar-indexer)
    ?~  chunk=(get-chunk u.location)  ~
    `[%chunk u.chunk]
  ::
  ++  get-from-index
    ^-  (unit update:uqbar-indexer)
    ?>  ?=(id:smart query-payload)
    ?~  location=get-location  ~
    ?~  chunk=(get-chunk u.location)
    ?-  query-type
        %grain
      =*  granary  p.+.u.chunk
      ?~  grain=(~(get by granary) query-payload)  ~
      `[%grain u.grain]
    ::
        ?(%to %from $egg)
      ?>  ?=([@ ^] u.location)  ::  [block-num town-id egg-num]
      =*  egg-num  egg-num.u.location
      =*  txs  -.u.chunk
      ?>  (lth egg-num (lent txs))
      =+  [hash=@ux =egg:smart]=(snag egg-num txs)
      ?>  =(query-payload hash)
      `[%egg egg]
    ::
    ==
  ::
  ++  get-location
    ^-  (unit location:uqbar-indexer)
    ?~  query-index=(~(get by index) query-type)  ~  :: TODO: crash instead?
    (~(get by query-index) query-payload)
  ::
  ++  get-chunk
    |=  location:uqbar-indexer
    ^-  (unit chunk:zig)
    =*  block-num  block-num.location
    =*  town-id  town-id.location
    ?>  (lth block-num (lent blocks))
    =+  [block-header block]=(snag block-num blocks)
    =*  chunks  q.block
    (~(get by chunks) town-id)
  ::
  --
::
--
