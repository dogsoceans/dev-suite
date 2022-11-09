/-  *pyro
/+  dbug, default-agent
::
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 ~]
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  bowl=bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
    hc    ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  :_  this
  %+  turn
    :~  [/ames/restore /effect/restore]
        [/ames/send /effect/send]
        [/dill/blit /effect/blit]
        :: [/eyre/sleep /effect/sleep]
        :: [/eyre/restore /effect/restore]
        :: [/eyre/thus /effect/thus]
        :: [/eyre/kill /effect/kill]
        [/behn/sleep /effect/sleep]
        [/behn/restore /effect/restore]
        [/behn/doze /effect/doze]
        [/behn/kill /effect/kill]
        :: eyre
        :: etc.
    ==
  |=  [=wire =path]
  [%pass wire %agent [our.bowl %pyro] %watch path]
++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  [~ this(state !<(state-0 old-vase))]
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  `this
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
  ::
      [%ames @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      =+  ef=!<([aqua-effect] q.cage.sign)
      ?+    i.t.wire  !!
          %restore  [(restore:ames:hc who.ef) this]
      ::
          %send
        ?>  ?=(%send -.q.ufs.ef)
        [(send:ames:hc now.bowl who.ef ufs.ef) this]
      ==
    ==
  ::
      [%behn @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      =+  ef=!<([aqua-effect] q.cage.sign)
      =^  cards  behn-piers
        ?+    i.t.wire  !!
            %sleep
          ?>  ?=(%sleep -.q.ufs.ef)
          abet-pe:sleep:(pe:behn:hc who.ef)
        ::
            %restore
          ?>  ?=(%restore -.q.ufs.ef)
          abet-pe:restore:(pe:behn:hc who.ef)
        ::
            %doze
          ?>  ?=(%doze -.q.ufs.ef)
          abet-pe:(doze:(pe:behn:hc who.ef) ufs.ef)
            %kill     !!  ::`(~(del by piers) who)
        ==
      [cards this]
    ==
  ::
      [%dill %blit ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      =+  ef=!<([aqua-effect] q.cage.sign)
      ?>  ?=(%blit -.q.ufs.ef)
      [(blit:dill:hc ef) this]
    ==
  ==
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::
=|  behn-piers=(map ship behn-pier)
|_  bowl=bowl:gall
++  ames
  |%
  ++  emit-aqua-events
    |=  aes=(list aqua-event)
    ^-  (list card:agent:gall)
    [%pass /aqua-events %agent [our.bowl %aqua] %poke %aqua-events !>(aes)]~
  ::
  ++  restore
    |=  who=@p
    ^-  (list card:agent:gall)
    %-  emit-aqua-events
    [%event who [/a/newt/0v1n.2m9vh %born ~]]~
  ::
  ++  send
    ::  XX unix-timed events need now
    |=  [now=@da sndr=@p way=wire %send lan=lane:^ames pac=@]
    ^-  (list card:agent:gall)
    =/  rcvr=ship  (lane-to-ship lan)
    =/  hear-lane  (ship-to-lane sndr)
    %-  emit-aqua-events
    [%event rcvr /a/newt/0v1n.2m9vh %hear hear-lane pac]~
  ::  +lane-to-ship: decode a ship from an aqua lane
  ::
  ::    Special-case one comet, since its address doesn't fit into a lane.
  ::
  ++  lane-to-ship
    |=  =lane:^ames
    ^-  ship
    ::
    ?-  -.lane
      %&  p.lane
      %|  =/  s  `ship``@`p.lane
          ?.  =(s 0xdead.beef.cafe)
            s
          ~bosrym-podwyl-magnes-dacrys--pander-hablep-masrym-marbud
    ==
  ::  +ship-to-lane: encode a lane to look like it came from .ship
  ::
  ::    Never shows up as a galaxy, because Vere wouldn't know that either.
  ::    Special-case one comet, since its address doesn't fit into a lane.
  ::
  ++  ship-to-lane
    |=  =ship
    ^-  lane:^ames
    :-  %|
    ^-  address:^ames  ^-  @
    ?.  =(ship ~bosrym-podwyl-magnes-dacrys--pander-hablep-masrym-marbud)
      ship
    0xdead.beef.cafe
  ::
  --
++  behn
  |%
  ++  pe
    |=  who=ship
    =+  (~(gut by behn-piers) who *behn-pier)
    =*  pier-data  -
    =|  cards=(list card:agent:gall)
    |%
    ++  this  .
    ++  abet-pe
      ^-  (quip card:agent:gall _behn-piers)
      =.  behn-piers  (~(put by behn-piers) who pier-data)
      [(flop cards) behn-piers]
    ::
    ++  emit-cards
      |=  cs=(list card:agent:gall)
      %_(this cards (weld cs cards))
    ::
    ++  emit-aqua-events
      |=  aes=(list aqua-event)
      %-  emit-cards
      [%pass /aqua-events %agent [our.bowl %aqua] %poke %aqua-events !>(aes)]~
    ::
    ++  sleep
      ^+  ..abet-pe
      =<  ..abet-pe(pier-data *behn-pier)
      ?~  next-timer
        ..abet-pe
      cancel-timer
    ::
    ++  restore
      ^+  ..abet-pe
      =.  this
        %-  emit-aqua-events
        [%event who [/b/behn/0v1n.2m9vh %born ~]]~
      ..abet-pe
    ::
    ++  doze
      |=  [way=wire %doze tim=(unit @da)]
      ^+  ..abet-pe
      ?~  tim
        ?~  next-timer
          ..abet-pe
        cancel-timer
      ?~  next-timer
        (set-timer u.tim)
      (set-timer:cancel-timer u.tim)
    ::
    ++  set-timer
      |=  tim=@da
      ~?  debug=|  [who=who %setting-timer tim]
      =.  next-timer  `tim
      =.  this  (emit-cards [%pass /(scot %p who) %arvo %b %wait tim]~)
      ..abet-pe
    ::
    ++  cancel-timer
      ~?  debug=|  [who=who %cancell-timer (need next-timer)]
      =.  this
        (emit-cards [%pass /(scot %p who) %arvo %b %rest (need next-timer)]~)
      =.  next-timer  ~
      ..abet-pe
    ::
    ++  take-wake
      |=  [way=wire error=(unit tang)]
      ~?  debug=|  [who=who %aqua-behn-wake now.bowl error=error]
      =.  next-timer  ~
      =.  this
        %-  emit-aqua-events
        ?^  error
          ::  Should pass through errors to aqua, but doesn't
          ::
          %-  (slog leaf+"aqua-behn: timer failed" u.error)
          ~
        :_  ~
        ^-  aqua-event
        :+  %event  who
        [/b/behn/0v1n.2m9vh [%wake ~]]
      ..abet-pe
    --
  --
++  dill
  |%
  ++  blit
    |=  [who=@p way=wire %blit blits=(list blit:^dill)]
    ^-  (list card:agent:gall)
    =/  last-line
      %+  roll  blits
      |=  [b=blit:^dill line=tape]
      ?-    -.b
          %lin  (tape p.b)
          %klr  (tape (zing (turn p.b tail)))
          %mor  ~&  "{<who>}: {line}"  ""
          %hop  line
          %bel  line
          %clr  ""
          %sag  ~&  [%save-jamfile-to p.b]  line
          %sav  ~&  [%save-file-to p.b]  line
          %url  ~&  [%activate-url p.b]  line
      ==
    ~?  !=(~ last-line)  last-line
    ~
  --
--
