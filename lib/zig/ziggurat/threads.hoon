/-  spider,
    pyro=zig-pyro,
    wallet=zig-wallet,
    zig=zig-ziggurat
/+  strandio,
    pyro-lib=pyro-pyro,
    smart=zig-sys-smart,
    zig-lib=zig-ziggurat
::
=*  strand          strand:spider
=*  build-file      build-file:strandio
=*  get-bowl        get-bowl:strandio
=*  get-time        get-time:strandio
=*  poke-our        poke-our:strandio
=*  scry            scry:strandio
=*  send-raw-card   send-raw-card:strandio
=*  sleep           sleep:strandio
=*  take-fact       take-fact:strandio
=*  take-kick       take-kick:strandio
=*  take-poke-ack   take-poke-ack:strandio
=*  take-sign-arvo  take-sign-arvo:strandio
=*  wait            wait:strandio
=*  warp            warp:strandio
=*  watch-our       watch-our:strandio
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
  ;<  =bowl:strand  bind:m  get-bowl
  =*  w    (scot %p who)
  =*  now  (scot %da now.bowl)
  %+  scry  mold
  (weld /gx/pyro/i/[w]/[care]/[w]/[app]/[now] path)
::
++  send-pyro-scry-with-expectation
  |=  [who=@p =mold care=@tas app=@tas =path expected=*]
  =/  m  (strand ,[mold ?])
  ^-  form:m
  ;<  result=mold  bind:m
    (send-pyro-scry who mold care app path)
  (pure:m [result =(expected result)])
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
          /[our]/pyro/[now]/i/[who]/cd/[who]/base/[now]/noun
      ==
    =/  desks=(list @tas)  ~(tap in desks-scry)
    |-
    ?~  desks  ~
    =*  desk  i.desks
    =/  apps=(set [@tas ?])
      .^  (set [@tas ?])
          %gx
          %+  weld  /[our]/pyro/[now]/i/[who]/ge/[who]/[desk]
          /[now]/apps
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
++  take-snapshot
  |=  $:  test-id=(unit @ux)
          step=@ud
          snapshot-ships=(list @p)
      ==
  =/  m  (strand ,~)
  ^-  form:m
  ?~  snapshot-ships  (pure:m ~)
  ;<  ~  bind:m
    %+  poke-our  %pyro
    :-  %pyro-action
    !>  ^-  action:pyro
    :+  %snap-ships
      ?~  test-id  /[project-name]/(scot %ud step)
      /[project-name]/(scot %ux u.test-id)/(scot %ud step)
    snapshot-ships
  (pure:m ~)
::
++  deploy-contract
  |=  $:  who=@p
          contract-jam-path=path
          mutable=?
          publish-contract-id=(unit @ux)  ::  ~ -> 0x1111.1111
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  =/  address=@ux  (~(got by ship-to-address) who)
  ;<  state=state-0:zig  bind:m  get-state
  =/  =project:zig
    (~(got by projects.state) project-name)
  =/  =desk:zig  (got-desk:zig-lib project desk-name)
  =*  rh  (scot %p repo-host.repo-info.desk)
  =*  rn  repo-name.repo-info.desk
  =*  bn  branch-name.repo-info.desk
  =*  ch  commit-hash.repo-info.desk
  =*  co=@ta  ?~  ch  %head  (scot %ux u.ch)
  ;<  code-atom=(unit @)  bind:m
    %+  scry  (unit @)
    %-  snoc  :_  %noun
    `path`[%gx %linedb rh rn bn co contract-jam-path]
  ?~  code-atom  !!  :: TODO
  =/  code  [- +]:(cue u.code-atom)
  |^
  ;<  empty-vase=vase  bind:m
    %-  send-pyro-poke
    :^  who  who  %uqbar
    :-  %wallet-poke 
    !>  ^-  wallet-poke:wallet
        :*  %transaction
            origin=~
            from=address
            contract=pci
            town=town-id
            [%noun %deploy mutable code interface=~]
        ==
  (pure:m !>(`@ux`compute-contract-hash))
  ::
  ++  town-id
    ^-  @ux
    0x0  ::  hardcode
  ::
  ++  pci
    ^-  @ux
    (fall publish-contract-id 0x1111.1111)
  ::
  ++  compute-contract-hash
    ^-  @ux
    %-  hash-pact:smart
    [?.(mutable 0x0 pci) address town-id code]
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
    ':sequencer|batch'
  (pure:m gate-output)
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
      ::  /i//whey from sys/vane/iris/hoon:386
      ;<  maz=(list mass)  bind:m  (scry (list mass) /i//whey)
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
      [/gall/use/spider/0w1.SsEZ5/~nec/thread %docket]
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
    :_  ~
    /ames/pump
  ::
  ++  ignored-realship-timer-prefixes
    ^-  (list path)
    :~  /ames/pump
        /eyre/channel
        /eyre/sessions
        /gall/use/eth-watcher
        /gall/use/hark-system-hook
        /gall/use/hark
        /gall/use/linedb
        /gall/use/notify
        /gall/use/ping
        /gall/use/pyre
        /gall/use/spider
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
++  fetch-repo
  |=  $:  repo-host=@p
          repo-name=@tas
          branch-name=@tas
          followup-action=(unit vase)
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  ~  bind:m
    %+  poke-our  %linedb
    :-  %linedb-action
    !>  [%fetch repo-host repo-name branch-name]
  ;<  ~  bind:m  (sleep ~s10)  ::  TODO: add %linedb update on action complete and wait for that rather than doing this hacky sleep
  ?~  followup-action  (pure:m !>(~))
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    [%ziggurat-action u.followup-action]
  (pure:m !>(~))
::
++  branch-if-remote
  |=  [project-name=@tas desk-name=@tas]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  state=state-0:zig  bind:m  get-state
  ;<  =bowl:strand  bind:m  get-bowl
  =/  =project:zig  (~(got by projects.state) project-name)
  =/  =desk:zig  (got-desk:zig-lib project desk-name)
  =*  repo-host    repo-host.repo-info.desk
  =*  repo-name    repo-name.repo-info.desk
  =*  branch-name  branch-name.repo-info.desk
  ?:  =(our.bowl repo-host)  (pure:m !>(repo-info.desk))
  ;<  ~  bind:m
    %+  poke-our  %linedb
    :-  %linedb-action
    !>
    [%branch repo-host repo-name branch-name branch-name]
  =.  repo-host.repo-info.desk  our.bowl
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  ~
    :-  %set-ziggurat-state
    %=  state
        projects
      %+  ~(put by projects.state)  project-name
      (put-desk:zig-lib project desk-name desk)
    ==
  (pure:m !>(repo-info.desk))
::
++  save-file
  |=  [file-path=path file-contents=@]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  repo-info-vase=vase  bind:m
    (branch-if-remote project-name desk-name)
  =+  !<(=repo-info:zig repo-info-vase)
  =*  repo-host    (scot %p repo-host.repo-info)
  =*  repo-name    repo-name.repo-info
  =*  branch-name  branch-name.repo-info
  =*  commit-hash  commit-hash.repo-info
  =*  commit=@ta
    ?~  commit-hash  %head  (scot %uv u.commit-hash)
  ;<  snap=(map path wain)  bind:m
    %+  scry  (map path wain)
    :+  %gx  %linedb
    /[repo-host]/[repo-name]/[branch-name]/[commit]/noun
  :: ?~  snap  !!  ::  TODO
  ;<  ~  bind:m
    %+  poke-our  %linedb
    :-  %linedb-action
    !>
    :^  %commit  repo-name  branch-name
    %+  ~(put by snap)  file-path
    ?.  ((sane %t) file-contents)  ~[file-contents]
    (to-wain:format file-contents)
  (pure:m !>(~))
::
++  does-desk-exist
  |=  desk-name=@tas
  =/  m  (strand ,?)
  ^-  form:m
  ;<  a=arch  bind:m  (scry arch /cy/[desk-name])
  (pure:m |(?=(^ fil.a) ?=(^ dir.a)))
::
++  build
  |=  [request-id=(unit @t) file-path=path]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  =bowl:strand  bind:m  get-bowl
  ;<  build-result=(unit vase)  bind:m
    (build-file [our.bowl desk-name %da now.bowl] file-path)
  (pure:m ?~(build-result !>(~) u.build-result))
::
++  create-desk
  |=  =update-info:zig
  =/  m  (strand ,vase)
  =*  desk-name  desk-name.update-info
  |^  ^-  form:m
  ;<  ~  bind:m  make-merge
  ;<  ~  bind:m  make-mount
  ;<  ~  bind:m  make-bill
  ;<  ~  bind:m  make-deletions
  ;<  ~  bind:m  (sleep ~s1)
  (pure:m !>(~))
  ::
  ++  make-merge
    =/  m  (strand ,~)
    ^-  form:m
    ;<  =bowl:strand  bind:m  get-bowl
    %^  send-clay-card  /merge  %merg
    [desk-name our.bowl q.byk.bowl da+now.bowl %init]
  ::
  ++  make-mount
    =/  m  (strand ,~)
    ^-  form:m
    ;<  =bowl:strand  bind:m  get-bowl
    %^  send-clay-card  /mount  %mont
    [desk-name [our.bowl desk-name da+now.bowl] /]
  ::
  ++  make-bill
    =/  m  (strand ,~)
    ^-  form:m
    %^  send-clay-card  /bill  %info
    :+  desk-name  %&
    [/desk/bill %ins %bill !>(~[desk-name])]~
  ::
  ++  make-deletions
    =/  m  (strand ,~)
    ^-  form:m
    %^  send-clay-card  /delete  %info
    [desk-name %& (clean-desk:zig-lib desk-name)]
  --
::
++  send-clay-card
  |=  [w=wire =task:clay]
  =/  m  (strand ,~)
  ^-  form:m
  (send-raw-card %pass w %arvo %c task)
::
++  make-snap
  |=  [project-name=@t request-id=(unit @t)]
  =/  m  (strand ,vase)
  ^-  form:m
  ?:  =('zig' project-name)  (pure:m !>(~))
  ;<  =update:zig  bind:m
    (scry update:zig /gx/ziggurat/focused-project/noun)
  =/  focused-project=@t
    ?>  ?=(^ update)  :: TODO: ?
    ?>  ?=(%focused-project -.update)
    ?>  ?=(%& -.payload.update)
    p.payload.update
  ?:  =('' focused-project)  (pure:m !>(~))
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    [focused-project %$ request-id %take-snapshot ~]
  (pure:m !>(~))
::
++  get-state
  =/  m  (strand ,state-0:zig)
  ^-  form:m
  ;<  =update:zig  bind:m
    %+  scry  update:zig
    /gx/ziggurat/get-ziggurat-state/noun
  ?>  ?=(^ update)
  ?>  ?=(%ziggurat-state -.update)
  ?>  ?=(%& -.payload.update)
  (pure:m p.payload.update)
::
++  iterate-over-repo-dependencies
  =/  m  (strand ,vase)
  |=  $:  =repo-dependencies:zig
          gate=$-(repo-info:zig form:m)
      ==
  ^-  form:m
  |-
  ?~  repo-dependencies  (pure:m !>(~))
  ;<  empty-vase=vase  bind:m  (gate i.repo-dependencies)
  $(repo-dependencies t.repo-dependencies)
::
++  iterate-over-desks
  =/  m  (strand ,vase)
  |=  [=repo-dependencies:zig gate=$-(@tas form:m)]
  ^-  form:m
  |-
  ?~  repo-dependencies  (pure:m !>(~))
  =*  desk-name  repo-name.i.repo-dependencies
  ;<  empty-vase=vase  bind:m  (gate desk-name)
  $(repo-dependencies t.repo-dependencies)
::
++  start-commit-thread
  |=  whos=(list @p)
  |=  $:  repo-host=@p
          repo-name=@tas
          branch-name=@tas
          commit-hash=(unit @ux)
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  ~  bind:m
    %-  commit-from-linedb:pyro-lib
    [whos repo-host repo-name branch-name commit-hash]
  (pure:m !>(~))
::
++  commit-install-start
  |=  $:  whos=(list @p)
          =repo-dependencies:zig
          install=(map @tas (list @p))
          start-apps=(map @tas (list @tas))
      ==
  =/  commit-poll-duration=@dr  ~s1
  =/  start-poll-duration=@dr   (div ~s1 10)
  |^
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  =bowl:strand  bind:m  get-bowl
  ;<  empty-vase=vase  bind:m
    %+  iterate-over-repo-dependencies  repo-dependencies
    (start-commit-thread whos)
  ;<  state=state-0:zig  bind:m  get-state
  =/  =project:zig  (~(got by projects.state) project-name)
  =.  sync-desk-to-vship.project
    %-  ~(gas ju sync-desk-to-vship.project)
    (turn whos |=(who=@p [desk-name who]))
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :-  project-name
    :^  desk-name  ~  %set-ziggurat-state
    %=  state
        projects
      (~(put by projects.state) project-name project)
    ==
  ~&  %cis^%0
  =*  desk-names=(list @tas)
    %+  turn  repo-dependencies
    |=([@ desk-name=@tas *] desk-name)
  ;<  ~  bind:m
    (iterate-over-whos whos (block-on-commit desk-names))
  ?:  ?|  =(0 ~(wyt by install))
          (~(all by install) |=(a=(list @) ?=(~ a)))
      ==
    (pure:m !>(~))
  ~&  %cis^%1
  ;<  ~  bind:m  install-and-start-apps
  ~&  %cis^%2
  (pure:m !>(~))
  ::
  ++  scry-virtualship-desks
    |=  who=@p
    =/  m  (strand ,(set @tas))
    ^-  form:m
    =/  w=@ta  (scot %p who)
    (scry (set @tas) /gx/pyro/i/[w]/cd/[w]//0/noun)
  ::
  ++  virtualship-desks-exist
    |=  [who=@p desired-desk-names=(set @tas)]
    =/  m  (strand ,?)
    ^-  form:m
    ;<  existing-desk-names=(set @tas)  bind:m
      (scry-virtualship-desks who)
    %-  pure:m
    .=  desired-desk-names
    (~(int in existing-desk-names) desired-desk-names)
  ::
  ++  block-on-commit
    |=  desk-names=(list @tas)
    |=  who=@p
    =/  m  (strand ,~)
    ^-  form:m
    |-
    ;<  ~  bind:m  (sleep commit-poll-duration)
    ;<  does-exist=?  bind:m
      %+  virtualship-desks-exist  who
      (~(gas in *(set @tas)) desk-names)
    ?.  does-exist  $
    (pure:m ~)
  ::
  ++  virtualship-is-running-app
    |=  [who=@p app=@tas]
    =/  m  (strand ,?)
    ^-  form:m
    =/  w=@ta    (scot %p who)
    (scry ? /gx/pyro/i/[w]/gu/[w]/[app]/0/noun)
  ::
  ++  iterate-over-whos
    =/  m  (strand ,~)
    |=  [whos=(list @p) gate=$-(@p form:m)]
    ^-  form:m
    |-
    ?~  whos  (pure:m ~)
    =*  who  i.whos
    ;<  ~  bind:m  (gate who)
    $(whos t.whos)
  ::
  ++  do-install-desk
    |=  desk-name=@tas
    |=  who=@p
    =/  m  (strand ,~)
    ^-  form:m
    ;<  empty-vase=vase  bind:m
      %+  send-pyro-dojo  who
      (crip "|install our {<desk-name>}")
    (pure:m ~)
  ::
  ++  block-on-start
    |=  [who=@p next-app=@tas]
    =/  m  (strand ,~)
    ^-  form:m
    |-
    ;<  ~  bind:m  (sleep start-poll-duration)
    ;<  is-running=?  bind:m
      (virtualship-is-running-app who next-app)
    ?.  is-running  $
    (pure:m ~)
  ::
  ++  do-start-apps
    |=  [desk-name=@tas start-apps=(list @tas)]
    |=  who=@p
    =/  m  (strand ,~)
    ^-  form:m
    |-
    ?~  start-apps  (pure:m ~)
    =*  next-app  i.start-apps
    ;<  empty-vase=vase  bind:m
      %+  send-pyro-dojo  who
      (crip "|start {<`@tas`desk-name>} {<`@tas`next-app>}")
    ;<  ~  bind:m  (block-on-start who next-app)
    $(start-apps t.start-apps)
  ::
  ++  install-and-start-apps
    =/  m  (strand ,~)
    ^-  form:m
    =/  installs  ~(tap by install)
    |-
    ?~  installs  (pure:m ~)
    =*  desk-name        p.i.installs
    =*  whos-to-install  q.i.installs
    ;<  ~  bind:m
      %+  iterate-over-whos  whos-to-install
      (do-install-desk desk-name)
    ?~  apps-to-start=(~(get by start-apps) desk-name)
      $(installs t.installs)
    ;<  ~  bind:m
      %+  iterate-over-whos  whos-to-install
      (do-start-apps desk-name u.apps-to-start)
    $(installs t.installs)
  --
::
++  setup-project
  |=  $:  repo-host=@p
          request-id=(unit @t)
          =repo-dependencies:zig
          =config:zig
          whos=(list @p)
          install=(map @tas (list @p))
          start-apps=(map @tas (list @tas))
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  %sp^%0
  ;<  state=state-0:zig  bind:m  get-state
  =/  old-focused-project=@tas  focused-project.state
  |^
  ?:  =('global' project-name)
    ;<  ~  bind:m
      %-  send-error
      (crip "{<`@tas`project-name>} face reserved")
    return-failure
  ;<  ~  bind:m  get-dependency-repos
  ~&  %sp^%1
  ;<  new-state=state-0:zig  bind:m  set-initial-state
  =.  state  new-state
  ~&  %sp^%2
  ;<  =bowl:strand  bind:m  get-bowl
  ;<  empty-vase=vase  bind:m
    %+  iterate-over-desks
      :_  repo-dependencies
      [our.bowl project-name %master ~]
    make-read-repo
  ;<  empty-vase=vase  bind:m
    %+  iterate-over-desks
      :_  repo-dependencies
      [our.bowl project-name %master ~]
    make-watch-repo
  ;<  ~  bind:m  start-new-ships
  ~&  %sp^%3
  ;<  ~  bind:m  send-new-project-update
  ~&  %sp^%4
  ;<  ~  bind:m  send-state-views
  ~&  %sp^%5
  ;<  empty-vase=vase  bind:m
    %-  commit-install-start
    [whos repo-dependencies install start-apps]
  ~&  %sp^%6
  return-success
  ::
  ++  send-state-views
    =/  m  (strand ,~)
    ^-  form:m
    ;<  =bowl:strand  bind:m  get-bowl
    =/  state-views=(unit state-views:zig)
      %.  [repo-host project-name %master ~]  ::  TODO: generalize from [%master ~]
      make-state-views:zig-lib(our.bowl our.bowl, now.bowl now.bowl)
    ?~  state-views  (pure:m ~)
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :^  project-name  %$  request-id
      [%send-state-views u.state-views]
    (pure:m ~)
  ::
  ++  get-dependency-repos
    =/  m  (strand ,~)
    ^-  form:m
    |-
    ?~  repo-dependencies  (pure:m ~)
    =*  dep           i.repo-dependencies
    =*  repo-host     repo-host.dep
    =*  repo-name     repo-name.dep
    =*  branch-name   branch-name.dep
    :: =*  desired-hash  desired-hash.dep
    ;<  ~  bind:m
      %+  poke-our  %linedb
      :-  %linedb-action
      !>([%fetch repo-host repo-name branch-name])
    $(repo-dependencies t.repo-dependencies)
  ::
  ++  get-cass
    |=  [who=@p desk-name=@tas when=@da]
    =/  m  (strand ,cass:clay)
    ^-  form:m
    ;<  =riot:clay  bind:m
      (warp who desk-name ~ %sing %w da+when /)
    ?~  riot  !!  :: TODO
    (pure:m !<(cass:clay q.r.u.riot))
  ::
  ++  get-dome
    |=  [who=@p desk-name=@tas]
    =/  m  (strand ,dome:clay)
    ^-  form:m
    ;<  now=@da  bind:m  get-time
    ;<  =riot:clay  bind:m
      (warp who desk-name ~ %sing %v da+now /)
    ?~  riot  !!  :: TODO
    (pure:m !<(dome:clay q.r.u.riot))
  ::
  ++  get-revision-number-of-hash
    |=  [desired-hash=@ux =dome:clay]
    ^-  (unit @ud)
    =/  commits=(list (pair @ud @uvi))  ~(tap by hit.dome)
    |-
    ?~  commits  ~
    =*  revision-number  p.i.commits
    =*  commit-hash      q.i.commits
    ?.  =(desired-hash commit-hash)  $(commits t.commits)
    `revision-number
  ::
  ++  send-error
    |=  message=@t
    =/  m  (strand ,~)
    ^-  form:m
    =*  new-project-error
      %~  new-project  make-error-vase:zig-lib
      :_  %error
      [project-name desk-name %setup-project request-id]
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  request-id
    :-  %send-update
    !<(update:zig (new-project-error message))
  ::
  ++  send-new-project-update
    =/  m  (strand ,~)
    ^-  form:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  request-id
    :-  %send-update
    !<  update:zig
    %.  make-sync-desk-to-vship
    %~  new-project  make-update-vase:zig-lib
    [project-name %$ %setup-project request-id]
  ::
  ++  start-new-ships
    =/  m  (strand ,~)
    ^-  form:m
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :-  project-name
      [%$ request-id %start-pyro-ships whos]
    (sleep ~s1)
  ::
  ++  make-sync-desk-to-vship
    ^-  sync-desk-to-vship:zig
    =*  repo-dependency-names=(list @tas)
      %+  turn  repo-dependencies
      |=([@ desk-name=@tas *] desk-name)
    %-  ~(gas by *sync-desk-to-vship:zig)
    %+  turn  repo-dependency-names
    |=  desk-name=@tas
    [desk-name (~(gas in *(set @p)) whos)]
  ::
  ++  set-initial-state
    =/  m  (strand ,state-0:zig)
    ^-  form:m
    ;<  =bowl:strand  bind:m  get-bowl
    =/  =project:zig
      (~(gut by projects.state) project-name *project:zig)
    =.  desks.project
      %+  turn
        :_  repo-dependencies
        `repo-info:zig`[our.bowl project-name %master ~]
      |=  =repo-info:zig
      =|  =desk:zig
      :-  repo-name.repo-info
      desk(name repo-name.repo-info, repo-info repo-info)
    =.  start-apps.project  start-apps
    =.  state
      %=  state
          focused-project  project-name
      ::
          projects
        %+  ~(put by projects.state)  project-name
        project(sync-desk-to-vship make-sync-desk-to-vship)
      ::
          configs
        %+  ~(put by configs.state)  project-name
        %.  ~(tap by config)
        ~(gas by (~(gut by configs.state) project-name ~))
      ==
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :-  project-name
      [desk-name request-id %set-ziggurat-state state]
    (pure:m state)
  ::
  ++  make-watch-repo
    |=  desk-name=@tas
    =/  m  (strand ,vase)
    ^-  form:m
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :^  project-name  desk-name  request-id
      [%watch-repo-for-changes ~]
    (pure:m !>(~))
  ::
  ++  make-read-repo
    |=  desk-name=@tas
    =/  m  (strand ,vase)
    ^-  form:m
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :^  project-name  desk-name  request-id
      [%read-repo ~]
    (pure:m !>(~))
  :: ::
  :: ++  make-read-desk
  ::   |=  desk-name=@tas
  ::   =/  m  (strand ,~)
  ::   ^-  form:m
  ::   %+  poke-our  %ziggurat
  ::   :-  %ziggurat-action
  ::   !>  ^-  action:zig
  ::   [project-name desk-name request-id %read-desk ~]
  ::
  ++  return-failure
    =/  m  (strand ,vase)
    ^-  form:m
    ;<  state=state-0:zig  bind:m  get-state
    =.  state  state(focused-project old-focused-project)
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :-  project-name
      [desk-name request-id %set-ziggurat-state state]
    (pure:m !>(`?`%.n))
  ::
  ++  return-success
    =/  m  (strand ,vase)
    ^-  form:m
    ;<  ~  bind:m  (block-on-previous-operation `project-name)
    (pure:m !>(`?`%.y))
  --
--
