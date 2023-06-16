/-  pyro,
    spider,
    eng=zig-engine,
    ui=zig-indexer,
    wallet=zig-wallet,
    zig=zig-ziggurat
/+  strandio,
    pyro-lib=pyro,
    smart=zig-sys-smart,
    zig-lib=zig-ziggurat
::
=*  strand          strand:spider
=*  get-bowl        get-bowl:strandio
=*  get-time        get-time:strandio
=*  poke-our        poke-our:strandio
=*  scry            scry:strandio
=*  sleep           sleep:strandio
=*  wait            wait:strandio
::
|_  $:  project-name=@t
        desk-name=@tas
        ship-to-address=(map @p @ux)
    ==
++  send-discrete-pyro-dojo
  |=  [who=@p payload=@t]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  empty-vase=vase  bind:m  (send-pyro-dojo who payload)
  ::  ensure %pyro dojo send has completed before moving on
  ;<  ~  bind:m  (block-on-previous-operation `project-name)
  (pure:m !>(~))
::
++  send-pyro-dojo
  |=  [who=@p payload=@t]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  ~  bind:m  (dojo:pyro-lib who (trip payload))
  (pure:m !>(~))
::
++  send-pyro-scry
  |*  [who=@p =mold care=@tas app=@tas =path]
  =/  m  (strand ,mold)
  ^-  form:m
  =*  w    (scot %p who)
  %+  scry  mold
  (weld /gx/pyro/i/[w]/[care]/[w]/[app]/0 path)
::
++  send-pyro-chain-scry
  |=  town-id=@ux
  =/  m  (strand ,(each chain:eng @t))
  ^-  form:m
  ;<  chain-state=(each (map @ux batch:ui) @t)  bind:m
    send-pyro-chain-state-scry
  ?:  ?=(%| -.chain-state)  (pure:m [%| p.chain-state])
  ?~  town-batch=(~(get by p.chain-state) town-id)
    %-  pure:m
    :-  %|
    %^  cat  3
      'did not find town-id {<town-id>} in chain-state'
    ' scry amongst {<~(key by p.chain-state)>}'
  (pure:m [%& chain.u.town-batch])
::
++  send-pyro-transactions-scry
  |=  town-id=@ux
  =/  m  (strand ,(each processed-txs:eng @t))
  ^-  form:m
  ;<  chain-state=(each (map @ux batch:ui) @t)  bind:m
    send-pyro-chain-state-scry
  ?:  ?=(%| -.chain-state)  (pure:m [%| p.chain-state])
  ?~  town-batch=(~(get by p.chain-state) town-id)
    %-  pure:m
    :-  %|
    %^  cat  3
      'did not find town-id {<town-id>} in chain-state'
    ' scry amongst {<~(key by p.chain-state)>}'
  (pure:m [%& transactions.u.town-batch])
::
++  send-pyro-chain-state-scry
  =/  m  (strand ,(each (map @ux batch:ui) @t))
  ^-  form:m
  ;<  =bowl:strand  bind:m  get-bowl
  =*  zl  zig-lib(our.bowl our.bowl, now.bowl now.bowl)
  ;<  state=state-1:zig  bind:m  get-state
  %-  pure:m
  (get-chain-state:zl project-name configs.state)
::
++  send-discrete-pyro-poke-then-sleep
  |=  $:  sleep-time=@dr
          who=@p
          to=@p
          app=@tas
          mark=@tas
          payload=vase
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  return=vase  bind:m
    %-  send-discrete-pyro-poke
    [who to app mark payload]
  ;<  ~  bind:m  (sleep sleep-time)
  (pure:m return)
::
++  send-discrete-pyro-poke
  |=  $:  who=@p
          to=@p
          app=@tas
          mark=@tas
          payload=vase
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  empty-vase=vase  bind:m  (send-pyro-poke who to app mark payload)
  ::  ensure %pyro poke send has completed before moving on
  ;<  ~  bind:m  (block-on-previous-operation `project-name)
  (pure:m !>(~))
::
++  send-pyro-poke
  |=  [who=@p to=@p app=@tas mark=@tas payload=vase]
  =/  m  (strand ,vase)
  ^-  form:m
  ::  if mark is not found poke will fail
  ;<  =bowl:strand  bind:m  get-bowl
  |^
  ?:  is-mar-found
    ::  found mark: proceed
    ;<  ~  bind:m  (poke:pyro-lib who to app mark q.payload)
    (pure:m !>(~))
  ::  mark not found: warn and attempt to fallback to
  ::   equivalent %dojo step rather than failing outright
  ~&  %ziggurat-test-run^%poke-mark-not-found^mark
  (send-pyro-dojo convert-poke-to-dojo-payload)
  ::
  ++  is-mar-found
    ^-  ?
    =/  our=@ta  (scot %p our.bowl)
    =/  w=@ta  (scot %p who)
    =/  now=@ta  (scot %da now.bowl)
    ?~  desk=(find-desk-running-app app our w now)
      ~&  %ziggurat-test-run^%no-desk-running-app^app
      %.n
    =/  mar-paths=(list path)
      .^  (list path)
          %gx
          %+  weld  /[our]/pyro/[now]/i/[w]/ct
          /[w]/[u.desk]/[now]/mar/file-list
      ==
    =/  mars=(set @tas)
      %-  ~(gas in *(set @tas))
      %+  murn  mar-paths
      |=  p=path
      ?~  p  ~
      [~ `@tas`(rap 3 (join '-' (snip t.p)))]
    (~(has in mars) mark)
  ::
  ++  find-desk-running-app
    |=  [app=@tas our=@ta who=@ta now=@ta]
    ^-  (unit @tas)
    =/  desks-scry=(set @tas)
      .^  (set @tas)
          %gx
          /[our]/pyro/[now]/i/[who]/cd/[who]//[now]/noun
      ==
    =/  desks=(list @tas)  ~(tap in desks-scry)
    |-
    ?~  desks  ~
    =*  desk  i.desks
    =/  apps=(set [@tas ?])
      .^  (set [@tas ?])
          %gx
          %+  weld  /[our]/pyro/[now]/i/[who]/ge/[who]/[desk]
          /[now]/$/apps
      ==
    ?:  %.  app
        %~  has  in
        %-  ~(gas in *(set @tas))
        (turn ~(tap in apps) |=([a=@tas ?] a))
      `desk
    $(desks t.desks)
  ::
  ++  convert-poke-to-dojo-payload
    ^-  [@p @t]
    :-  who
    %+  rap  3
    :~  ':'
        ?:(=(who to) app (rap 3 to '|' app ~))
        ' &'
        mark
        ' '
        (crip (noah payload))
    ==
  --
::
++  load-snapshot
  |=  p=path
  =/  m  (strand ,~)
  ^-  form:m
  ;<  ~  bind:m
    %+  poke-our  %pyro
    [%pyro-action !>(`action:pyro`[%restore-snap p])]
  (pure:m ~)
::
++  take-snapshot
  |=  $:  p=path
          snapshot-ships=(list @p)
      ==
  =/  m  (strand ,~)
  ^-  form:m
  ?~  snapshot-ships  (pure:m ~)
  ;<  ~  bind:m
    %+  poke-our  %pyro
    :-  %pyro-action
    !>  ^-  action:pyro
    [%snap-ships p snapshot-ships]
  (pure:m ~)
::
++  expect
  |%
  ++  is-equal
    |=  [a=* b=*]
    ^-  ?
    =(a b)
  ::
  ++  tuple-contains
    |=  [nedl=* hstk=*]
    ^-  ?
    ?=(^ (tuple-find nedl hstk))
  ::
  ++  list-contains
    |=  [nedl=(list) hstk=(list)]
    ^-  ?
    ?=(^ (find nedl hstk))
  ::
  ++  set-contains
    |*  =mold
    |=  [item=mold items=(set mold)]
    ^-  ?
    (~(has in items) item)
  ::
  ++  map-key-contains
    |*  =mold
    |=  [item=mold items=(map mold *)]
    ^-  ?
    (~(has by items) item)
  ::
  ++  map-val-contains
    |=  [nedl=(list) items=(map * *)]
    ^-  ?
    ?=(^ (find nedl ~(val by items)))
  ::
  ++  tuple-find
    |=  [nedl=* hstk=*]
    =|  i=@ud
    |-  ^-  (unit @ud)
    =/  n  nedl
    =/  h  hstk
    |-
    ?:  |(=(~ n) =(~ h))  ~
    =/  in  ?@  n  [%& p=n]  (mule |.(-.n))
    =/  ih  ?@  h  [%& p=h]  (mule |.(-.h))
    ?:  |(?=(%| -.in) ?=(%| -.ih))  ~
    ?^  p.ih  $(h p.ih)
    =/  tn  (mule |.(+.n))
    =/  th  (mule |.(+.h))
    ?:  =(p.in p.ih)
      ?:  ?=(%| -.tn)               `i
      ?:  =(~ p.tn)                 `i
      ?:  ?=(%| -.th)               ~
      ?:  =(~ p.th)                 ~
      $(n p.tn, h p.th)
    ^$(i +(i), hstk +.hstk)
  --
::
++  send-wallet-transaction
  |=  $:  who=@p
          sequencer-host=@p
          gate=vase
          gate-args=*
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  ship-to-address
  =/  address=@ux  (~(got by ship-to-address) who)
  ;<  old-scry=(map @ux *)  bind:m
    %^  send-pyro-scry  who  (map @ux *)
    :+  %gx  %wallet
    /pending-store/(scot %ux address)/noun/noun
  ::
  ;<  gate-output=vase  bind:m
    !<(form:m (slym gate gate-args))
  ;<  ~  bind:m  (block-on-previous-operation `project-name)
  ::
  ;<  new-scry=(map @ux *)  bind:m
    %^  send-pyro-scry  who  (map @ux *)
    :+  %gx  %wallet
    /pending-store/(scot %ux address)/noun/noun
  ::
  =*  old-pending  ~(key by old-scry)
  =*  new-pending  ~(key by new-scry)
  =/  diff-pending=(list @ux)
    ~(tap in (~(dif in new-pending) old-pending))
  ?.  ?=([@ ~] diff-pending)
    ~&  %ziggurat-threads^%diff-pending-not-length-one^diff-pending
    !!
  ;<  empty-vase=vase  bind:m
    %-  send-discrete-pyro-poke
    :^  who  who  %uqbar
    :-  %wallet-poke
    !>  ^-  wallet-poke:wallet
    :^  %submit  from=address  hash=i.diff-pending
    gas=[rate=1 bud=1.000.000]
  ;<  ~  bind:m  (sleep ~s3)  ::  TODO: tune time
  ;<  empty-vase=vase  bind:m
    %+  send-discrete-pyro-dojo  sequencer-host
    '-zig!batch'
  (pure:m gate-output)
::
++  deploy-contract
  |=  $:  is-virtualnet-deployment=(each @p from=@ux)
          town-id=@ux
          contract-jam-path=path
          mutable=?
          publish-contract-id=(unit @ux)  ::  ~ -> 0x1111.1111
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  %z^%dc^%0
  ;<  state=state-1:zig  bind:m  get-state
  =/  =project:zig
    (~(got by projects.state) project-name)
  =/  =desk:zig  (got-desk:zig-lib project desk-name)
  =*  rh  (scot %p repo-host.repo-info.desk)
  =*  rn  repo-name.repo-info.desk
  =*  bn  branch-name.repo-info.desk
  =*  ch  commit-hash.repo-info.desk
  =*  co=@ta  ?~  ch  %head  (scot %ux u.ch)
  ~&  %z^%dc^%1
  ~&  %z^%dc^%cjp^`path`contract-jam-path
  ~&  :^  %gx  %linedb  rh
      [rn bn co (snoc `path`contract-jam-path %noun)]
  ;<  =bowl:strand  bind:m  get-bowl
  =+  .^  code-atom=(unit @)
          %gx
          :^  (scot %p our.bowl)  %linedb
            (scot %da now.bowl)
          [rh rn bn co (snoc contract-jam-path %noun)]
      ==
  :: ;<  code-atom=(unit @)  bind:m
  ::   %+  scry  (unit @)
  ::   :^  %gx  %linedb  rh
  ::   [rn bn co (snoc contract-jam-path %noun)]
  ~&  %z^%dc^%2
  ?~  code-atom
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :^  project-name  desk-name  ~
      :-  %send-update
      !<  update:zig
      %.  ['contract not found' contract-jam-path]
      %~  deploy-contract  make-error-vase:zig-lib
      [[project-name desk-name %deploy-contract ~] %error]
    (pure:m !>(`(unit @ux)`~))
  ~&  %z^%dc^%3
  =/  code  [- +]:(cue u.code-atom)
  |^
  ::  TODO: send %update if contract-hash already exists
  =*  wallet-poke-cage=cage
    :-  %wallet-poke 
    !>  ^-  wallet-poke:wallet
        :*  %transaction
            origin=~
            from=address
            contract=pci
            town=town-id
            [%noun %deploy mutable code interface=~]
        ==
  ~&  %z^%dc^%4
  ;<  empty-vase=vase  bind:m
    ?:  ?=(%& -.is-virtualnet-deployment)
      =*  who  p.is-virtualnet-deployment
      (send-pyro-poke who who %uqbar wallet-poke-cage)
    ;<  ~  bind:m  (poke-our %wallet wallet-poke-cage)
    (pure:m !>(~))
  ~&  %z^%dc^%5
  =/  contract-hash=@ux  compute-contract-hash
  ~&  %z^%dc^%6
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  ~
    :-  %send-update
    !<  update:zig
    %.  [contract-hash contract-jam-path]
    %~  deploy-contract  make-update-vase:zig-lib
    [project-name desk-name %deploy-contract ~]
  ~&  %z^%dc^%7
  (pure:m !>(`(unit @ux)``contract-hash))
  ::
  ++  pci
    ^-  @ux
    (fall publish-contract-id 0x1111.1111)
  ::
  ++  compute-contract-hash
    ^-  @ux
    %-  hash-pact:smart
    [?.(mutable 0x0 pci) address town-id code]
  ::
  ++  address
    ^-  @ux
    ?:  ?=(%& -.is-virtualnet-deployment)
      (~(got by ship-to-address) p.is-virtualnet-deployment)
    from.p.is-virtualnet-deployment
  --
::
++  get-state
  =/  m  (strand ,state-1:zig)
  ^-  form:m
  ;<  =update:zig  bind:m
    %+  scry  update:zig
    /gx/ziggurat/get-ziggurat-state/noun
  ?>  ?=(^ update)
  ?>  ?=(%ziggurat-state -.update)
  ?>  ?=(%& -.payload.update)
  (pure:m p.payload.update)
::
++  block-on-previous-operation
  =+  done-duration=`@dr`~m1
  =+  iris-timeout-duration=`@dr`~s15
  |=  project-name=(unit @t)
  =|  iris-timeout=(map duct @da)
  |^
  =/  m  (strand ,~)
  ^-  form:m
  ;<  ~  bind:m  (sleep `@dr`1)
  |-
  ;<  is-stack-empty=(each ~ (map duct @da))  bind:m
    (get-is-stack-empty iris-timeout)
  ?:  ?=(%| -.is-stack-empty)
    =.  iris-timeout  p.is-stack-empty
    ;<  ~  bind:m  (sleep (div ~s1 4))
    $
  ;<  =bowl:strand  bind:m  get-bowl
  =/  timers=(list [@da duct])
    %+  get-real-and-virtual-timers  project-name
    [our now]:bowl
  ?~  timers  (pure:m ~)
  ~&  %z^%bopo^timers
  =*  soonest-timer  -.i.timers
  ?:  (lth (add now.bowl done-duration) soonest-timer)
    (pure:m ~)
  ;<  ~  bind:m  (wait +(soonest-timer))
  $
  ::
  ++  get-is-stack-empty
    |=  iris-timeout=(map duct @da)
    |^
    =/  m  (strand ,(each ~ (map duct @da)))
    ^-  form:m
    ;<  is-iris-empty=(each ~ (set duct))  bind:m  get-is-iris-empty
    ?:  ?=(%& -.is-iris-empty)  (pure:m [%.y ~])
    ;<  now=@da  bind:m  get-time
    =^  no-wait=?  iris-timeout
      %+  roll  ~(tap in p.is-iris-empty)
      |:  [d=`duct`~ no-wait=`?`%.y it=`(map duct @da)`iris-timeout]
      ?~  to=(~(get by it) d)
        [%.n (~(put by it) d (add now iris-timeout-duration))]
      ?:  (lth u.to now)  [no-wait it]  [%.n it]
    (pure:m ?:(no-wait [%.y ~] [%.n iris-timeout]))
    ::
    ++  get-is-iris-empty
      =/  m  (strand ,(each ~ (set duct)))
      ^-  form:m
      ::  /ix//$/whey from sys/vane/iris/hoon:398
      ;<  maz=(list mass)  bind:m  (scry (list mass) /ix//$/whey)
      =/  by-duct=(map duct @ud)
        %+  filter-iris-by-duct  ignored-iris-prefixes
        ((map duct @ud) p.q:(snag 3 maz))
      %-  pure:m
      ?:  =(0 ~(wyt by by-duct))  [%.y ~]
      [%.n ~(key by by-duct)]
    ::
    ++  ignored-iris-prefixes
      ^-  (list [path @tas])
      :_  ~
      [/gall/use/spider/0w1.SsEZ5 %docket]
    ::
    ++  filter-iris-by-duct
      ::  filter out those that have prefix that matches
      ::   an ignored-prefixes path and the first characters
      ::   of the next element in the path matches @tas
      |=  $:  ignored-prefixes=(list (pair path @tas))
              by-duct=(map duct @ud)
          ==
      ^-  (map duct @ud)
      %-  ~(gas by *(map duct @ud))
      %+  murn  ~(tap by by-duct)
      |=  [d=duct n=@ud]
      %+  roll  ignored-prefixes
      |:  [[p=`path`/ t=`@tas`%$] item=`(unit [duct @ud])``[d n]]
      ?~  d  ~
      =*  w  i.d
      =*  lp  (lent p)
      =*  lt  (met 3 t)
      ?.  =(p (scag lp w))  item
      ?:  =(t (cut 3 [0 lt] (snag lp w)))  ~
      item
    --
  ::
  ++  ignored-virtualship-timer-prefixes
    ^-  (list path)
    :+  /ames/fine/behn/wake
      /ames/pump
    ~
  ::
  ++  ignored-realship-timer-prefixes
    ^-  (list path)
    :~  /ames/fine/behn/wake
        /ames/pump
        /eyre/channel
        /eyre/sessions
        /gall/use
    ==
  ::
  ++  filter-timers
    |=  $:  now=@da
            ignored-prefixes=(list path)
            timers=(list [@da duct])
        ==
    ^-  (list [@da duct])
    %+  murn  timers
    |=  [time=@da d=duct]
    ?~  d               `[time d]  ::  ?
    ?:  (gth now time)  ~
    =*  w  i.d
    %+  roll  ignored-prefixes
    |:  [ignored-prefix=`path`/ timer=`(unit [@da duct])``[time d]]
    ?:  =(ignored-prefix (scag (lent ignored-prefix) w))  ~
    timer
  ::
  ++  get-virtualship-timers
    |=  [project-name=(unit @t) our=@p now=@da]
    ^-  (list [@da duct])
    =/  now-ta=@ta  (scot %da now)
    =/  ships=(list @p)
      (get-virtualships-synced-for-project project-name our now)
    %+  roll  ships
    |=  [who=@p all-timers=(list [@da duct])]
    =/  who-ta=@ta  (scot %p who)
    =/  timers=(list [@da duct])
      .^  (list [@da duct])
          %gx
          %+  weld  /(scot %p our)/pyro/[now-ta]/i/[who-ta]
          /bx/[who-ta]//[now-ta]/debug/timers/noun
      ==
    (weld timers all-timers)
  ::
  ++  get-virtualships-synced-for-project
    |=  [project-name=(unit @t) our=@p now=@da]
    ^-  (list @p)
    ?~  project-name  ~
    =+  .^  =update:zig
            %gx
            :-  (scot %p our)
            /ziggurat/(scot %da now)/sync-desk-to-vship/noun
        ==
    ?~  update                            ~
    ?.  ?=(%sync-desk-to-vship -.update)  ~  ::  TODO: throw error?
    ?:  ?=(%| -.payload.update)           ~  ::  "
    =*  sync-desk-to-vship
      sync-desk-to-vship.p.payload.update
    ~(tap in (~(get ju sync-desk-to-vship) u.project-name))
  ::
  ++  get-realship-timers
    |=  [our=@p now=@da]
    ^-  (list [@da duct])
    .^  (list [@da duct])
        %bx
        /(scot %p our)//(scot %da now)/debug/timers
    ==
  ::
  ++  get-real-and-virtual-timers
    |=  [project-name=(unit @t) our=@p now=@da]
    ^-  (list [@da duct])
    %-  sort
    :_  |=([a=(pair @da duct) b=(pair @da duct)] (lth p.a p.b))
    %+  weld
      %^  filter-timers  now  ignored-realship-timer-prefixes
      (get-realship-timers our now)
    %^  filter-timers  now  ignored-virtualship-timer-prefixes
    (get-virtualship-timers project-name our now)
  --
::
:: ++  read-pyro-subscription  ::  TODO
::   |=  [payload=read-sub-payload:zig expected=@t]
::   =/  m  (strand ,vase)
::   ;<  =bowl:strand  bind:m  get-bowl
::   =/  now=@ta  (scot %da now.bowl)
::   =/  scry-noun=*
::     .^  *
::         %gx
::         ;:  weld
::           /(scot %p our.bowl)/pyro/[now]/i/(scot %p who.payload)/gx
::           /(scot %p who.payload)/subscriber/[now]
::           /facts/(scot %p to.payload)/[app.payload]
::           path.payload
::           /noun
::         ==
::     ==
::   =+  ;;(fact-set=(set @t) scry-noun)
::   ?:  (~(has in fact-set) expected)  (pure:m !>(expected))
::   (pure:m !>((crip (noah !>(~(tap in fact-set))))))
:: ::
:: ++  send-pyro-subscription
::   |=  payload=sub-payload:zig
::   =/  m  (strand ,~)
::   ^-  form:m
::   ;<  ~  bind:m  (subscribe:pyro-lib payload)
::   (pure:m ~)
--
