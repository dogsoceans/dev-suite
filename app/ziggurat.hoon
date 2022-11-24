::  ziggurat [UQ| DAO]
::
::  Contract Playground
::
/-  spider
/+  dbug,
    default-agent,
    verb,
    *zig-ziggurat,
    engine=zig-sys-engine,
    seq=zig-sequencer,
    smart=zig-sys-smart
/*  smart-lib-noun  %noun  /lib/zig/sys/smart-lib/noun
/*  zink-cax-noun   %noun  /lib/zig/sys/hash-cache/noun
::
=|  inflated-state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  |^
  =/  smart-lib=vase  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =/  eng
    %~  engine  engine:engine
    ::  sigs off, hints off
    [smart-lib ;;((map * @) (cue +.+:;;([* * @] zink-cax-noun))) %.n %.n]
  =*  nec-address
    0x7a9a.97e0.ca10.8e1e.273f.0000.8dca.2b04.fc15.9f70
  =*  bud-address
    0xd6dc.c8ff.7ec5.4416.6d4e.b701.d1a6.8e97.b464.76de
  =/  w=wire  /self-wire
  :-  :+  :^  %pass  w  %agent
          :^  [our dap]:bowl  %poke  %ziggurat-action
          !>(`action`[%$ %add-custom-step poke-wallet-transaction])
        :^  %pass  w  %agent
        :^  [our dap]:bowl  %poke  %ziggurat-action
        !>(`action`[%$ %add-custom-step scry-indexer])
      ~
  %_    this
      state
    :_  [eng smart-lib]
    :*  %0
        ~
        ~
    ::
        %-  ~(gas by *(map @p address:smart))
        ~[[~nec nec-address] [~bud bud-address]]
    ::
        ~
        ~
    ==
  ==
  ::
  ++  scry-indexer
    :-  %scry-indexer
    '''
    |=  [indexer-path=path expected=@t]
    ^-  test-read-step:ziggurat
    :+  %scry
      :*  who=~nec  ::  hardcode: ~nec runs rollup/sequencer
          /zig/sur/zig/indexer/hoon
          'update:indexer'
          %gx
          %indexer
          indexer-path
      ==
    expected
    '''
  ::
  ++  poke-wallet-transaction
    :-  %poke-wallet-transaction
    '''
    |=  [[who=@p contract=@ux transaction=@t] expected=(list test-read-step:ziggurat)]
    ^-  test-write-step:ziggurat
    :+  %poke
      :^  who  %uqbar  %wallet-poke
      %-  crip
      """
      :*  %transaction
          from={<(~(got by addresses) who)>}
          contract={<contract>}
          town=0x0  ::  harcode
          action=[%text {<transaction>}]
      ==
      """
    expected
    '''
  --
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ::  on-load: pre-cue our compiled smart contract library
  =/  smart-lib=vase  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =/  eng
    %~  engine  engine:engine
    ::  sigs off, hints off
    [smart-lib ;;((map * @) (cue +.+:;;([* * @] zink-cax-noun))) %.n %.n]
  `this(state [!<(state-0 old-vase) eng smart-lib])
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  !!
      [%pyro-done ~]  `this
      [%project @ ~]
    ::  serve updates about state of a given project
    =/  name=@t  `@t`i.t.path
    ?~  proj=(~(get by projects) name)
      `this
    [(make-project-update name u.proj)^~ this]
  ::
      [%test-updates @ ~]
    ::  serve updates for all %run-tests executed
    ::  within a given contract project
    `this
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ::  TODO handle app project pokes in their own arm
  =^  cards  state
    ?+  mark  !!
      %ziggurat-action  (handle-poke !<(action vase))
    ==
  [cards this]
  ::
  ++  compile-custom-step
    |=  [tag=@tas =custom-step-definition addresses=^vase]
    ^-  (each ^vase @t)
    =/  ziggurat-sur=^vase
      .^  ^vase
          %ca
          %+  weld  /(scot %p our.bowl)/zig
          /(scot %da now.bowl)/sur/zig/ziggurat/hoon
      ==
    =/  compilation-result
      %-  mule
      |.
      %-  slap  :_  (ream custom-step-definition)
      ;:  slop
          addresses(p [%face %addresses p.addresses])
          ziggurat-sur(p [%face %ziggurat p.ziggurat-sur])
          !>(..zuse)
      ==
    ?:  ?=(%& -.compilation-result)  compilation-result
    :-  %|
    %-  crip
    %+  roll  p.compilation-result
    |=  [in=tank out=tape]
    :(weld ~(ram re in) "\0a" out)
  ::
  ++  handle-poke
    |=  act=action
    ^-  (quip card _state)
    ?-    -.+.act
        %new-project
      ~&  desk
      ~&  >  "scrying..."
      =/  desks=(set desk)
        .^  (set desk)
            %cd
            /(scot %p our.bowl)/[dap.bowl]/(scot %da now.bowl)
        ==
      ?:  (~(has in desks) project.act)
        ~|("%ziggurat: project desk already exists" !!)  ::  TODO: start project using this desk?
      ::  merge new desk, mount desk
      ::  currently using ziggurat desk as template -- should refine this
      ~&  >>  q.byk.bowl
      =/  merge-task  [%merg `@tas`project.act our.bowl q.byk.bowl da+now.bowl %init]
      =/  mount-task  [%mont `@tas`project.act [our.bowl `@tas`project.act da+now.bowl] /]
      =/  bill-task   [%info `@tas`project.act %& [/desk/bill %ins %bill !>(~[project.act])]~]
      =/  deletions-task  [%info `@tas`project.act %& (clean-desk project.act)]
      :-  :~  [%pass /merge-wire %arvo %c merge-task]
              [%pass /mount-wire %arvo %c mount-task]
              [%pass /save-wire %arvo %c bill-task]
              [%pass /save-wire %arvo %c deletions-task]
              =-  [%pass /self-wire %agent [our.bowl %ziggurat] %poke -]
              [%ziggurat-action !>(`action`project.act^[%read-desk ~])]
          ==
      %=  state
          projects
        %+  ~(put by projects)  project.act
        :*  dir=~  ::  populated by %read-desk
            user-files=(~(put in *(set path)) /app/[project.act]/hoon)
            to-compile=~
            next-contract-id=0xfafa.faf0
            error=~
            state=(starting-state user-address.act)
            noun-texts=(malt ~[[id.p:(designated-zigs-item user-address.act) '[balance=300.000.000.000.000.000.000 allowances=~ metadata=0x61.7461.6461.7465.6d2d.7367.697a]']])
            user-address.act
            user-nonce=0
            batch-num=0
            tests=~
        ==
      ==
    ::
        %populate-template
      !!  ::  TODO
      :: ::  spawn some hardcoded example tests and grains for %fungible and %nft templates
      :: =/  =project  (~(got by projects) project.act)
      :: ?<  ?=(%blank template.act)
      :: =.  project
      ::   ?:  ?=(%fungible template.act)
      ::     (fungible-template-project project metadata.act smart-lib-vase)
      ::   (nft-template-project project metadata.act smart-lib-vase)
      :: :-  (make-compile project.act our.bowl)^~
      :: state(projects (~(put by projects) project.act project))
    ::
        %delete-project
      ::  should show a warning on frontend before performing this one ;)
      `state(projects (~(del by projects) project.act))
    ::
        %save-file
      =/  =project  (~(got by projects) project.act)
      =.  user-files.project
        (~(put in user-files.project) file.act)
      :_  state(projects (~(put by projects) project.act project))
      :+  (make-save-file [project file text]:act)
        (make-compile project.act our.bowl)
      ~
    ::
        %delete-file
      ::  should show warning
      =/  =project  (~(got by projects) project.act)
      =:  user-files.project
        (~(del in user-files.project) file.act)
      ::
          to-compile.project
        (~(del by to-compile.project) file.act)
      ::
          p.chain.project
        ?~  remove-id=(~(get by to-compile.project) file.act)
          p.chain.project
        (del:big:engine p.chain.project u.remove-id)
      ==
      :_  state(projects (~(put by projects) project.act project))
      :+  (make-compile project.act our.bowl)
        =-  [%pass /del-wire %arvo %c -]
        [%info `@tas`project.act %& [file.act %del ~]~]
      ~
    ::
        %set-virtualnet-address
      =.  virtualnet-addresses
        (~(put by virtualnet-addresses) [who address]:act)
      =/  addresses=^vase  !>(virtualnet-addresses)
      :-  ~
      %=  state
          custom-step-definitions
        %-  ~(urn by custom-step-definitions)
        |=  [tag=@tas =custom-step-definition *]
        :-  custom-step-definition
        %^  compile-custom-step  tag  custom-step-definition
        addresses
      ==
    ::
        %register-contract-for-compilation
      =/  =project  (~(got by projects) project.act)
      ?:  (~(has by to-compile.project) file.act)  `state
      =:  next-contract-id.project
        (add next-contract-id.project 1)
      ::
          user-files.project
        (~(put in user-files.project) file.act)
      ::
          to-compile.project
        %+  ~(put by to-compile.project)  file.act
        next-contract-id.project
      ==
      :-  (make-compile project.act our.bowl)^~
      state(projects (~(put by projects) project.act project))
    ::
        %compile-contracts
      ::  for internal use -- app calls itself to scry clay
      =/  =project  (~(got by projects) project.act)
      =/  build-results=(list (trel path id:smart build-result))
        %^  build-contract-projects  smart-lib-vase
          /(scot %p our.bowl)/[project.act]/(scot %da now.bowl)
        to-compile.project
      ~&  "done building, got errors:"
      =/  [cards=(list card) errors=(list [path @t])]
        (save-compiled-projects project.act build-results)
      ~&  errors
      =:  errors.project  errors
          p.chain.project
        %+  gas:big:engine  p.chain.project
        %+  murn  build-results
        |=  [p=path q=id:smart r=build-result]
        ?:  ?=(%| -.r)  ~
        :+  ~  q
        :*  %|
            id=q
            source=0x0
            holder=user-address.project
            town-id=designated-town-id
            code=p.r
            interface=~
            types=~
        ==
      ==
      :-  [(make-read-desk project.act our.bowl) cards]
      state(projects (~(put by projects) project.act project))
    ::
        %read-desk
      ::  for internal use -- app calls itself to scry clay
      =/  =project  (~(got by projects) project.act)
      =.  dir.project
        =-  .^((list path) %ct -)
        /(scot %p our.bowl)/(scot %tas project.act)/(scot %da now.bowl)
      :-  (make-project-update project.act project)^~
      state(projects (~(put by projects) project.act project))
    ::
        %add-item
      =/  =id:smart  (hash-data:smart source.act holder.act town-id.act salt.act)
      (add-or-update-item project.act %& id +.+.act)
    ::
        %update-item
      (add-or-update-item project.act %& +.+.act)
    ::
        %delete-item
      ::  remove a grain from the granary
      =/  =project  (~(got by projects) project.act)
      =.  p.chain.project
        (del:big:engine p.chain.project id.act)
      :-  (make-project-update project.act project)^~
      state(projects (~(put by projects) project.act project))
    ::
        %add-test
      ::  generate an id for the test
      =/  =project  (~(got by projects) project.act)
      =/  test-id=@ux  `@ux`(sham test-steps.act)
      =.  tests.project
        %+  ~(put by tests.project)  test-id
        [name.act test-steps.act ~]
      :-  (make-project-update project.act project)^~
      state(projects (~(put by projects) project.act project))
    ::
        %delete-test
      =/  =project  (~(got by projects) project.act)
      =.  tests.project  (~(del by tests.project) id.act)
      :-  (make-project-update project.act project)^~
      state(projects (~(put by projects) project.act project))
    ::
      ::   %edit-test  :: TODO: update or remove
      :: =/  =project  (~(got by projects) project.act)
      :: ::  ream action to form calldata
      :: =+  (text-to-zebra-noun action.act smart-lib-vase)
      :: =/  =calldata:smart  [;;(@tas -.-) +.-]
      :: =/  new-error
      ::   ?~  expected-error.act  0
      ::   u.expected-error.act
      :: ::  get existing
      :: =.  tests.project
      ::   ?~  current=(~(get by tests.project) id.act)
      ::     %+  ~(put by tests.project)  id.act
      ::     :*  name.act
      ::         for-contract.act
      ::         action.act
      ::         calldata
      ::         ~
      ::         new-error
      ::         ~
      ::     ==
      ::   %+  ~(put by tests.project)  id.act
      ::   :*  name.act
      ::       for-contract.act
      ::       action.act
      ::       calldata
      ::       expected.u.current
      ::       (fall expected-error.act expected-error.u.current)
      ::       ~
      ::   ==
      :: :-  (make-project-update project.act project)^~
      :: state(projects (~(put by projects) project.act project))
    ::
        %run-test
      ~?  >  ?=(^ test-queue)  
        ::  XX  might want to fix this
        "%ziggurat: test-queue is non-empty, running queued tests first"
      :-  (make-run-queue our.bowl project.act)^~
      state(test-queue (~(put to test-queue) [project:act id.act]))
    ::
        %add-and-run-test
      ~?  >  ?=(^ test-queue)  
        ::  XX  might want to fix this
        "%ziggurat: test-queue is non-empty, running queued tests first"
      ::  generate an id for the test
      =/  =project  (~(got by projects) project.act)
      =/  test-id=@ux  `@ux`(sham test-steps.act)
      =.  tests.project
        %+  ~(put by tests.project)  test-id
        [name.act test-steps.act ~]
      :-  :~  (make-project-update project.act project)
              (make-run-queue our.bowl project.act)
          ==
      %=    state
          projects
        (~(put by projects) project.act project)
          test-queue
        (~(put to test-queue) [project:act test-id])
      ==
    ::
        %run-queue
      ?:  =(~ pyro-ships-ready)
        ~|("%ziggurat: run %start-pyro-ships before running tests" !!)
      ?:  !(~(all by pyro-ships-ready) same)
        ~|("%ziggurat: %pyro ships aren't ready yet, wait" !!)
      ?:  =(~ test-queue)
        ~|("%ziggurat: no tests in the queue" !!)
      =^  top  test-queue  ~(get to test-queue)
      =*  project-id  -.top
      =*  test-id     +.top
      ~&  >  "%ziggurat: running {(scow %ux test-id)}"
      =/  =project  (~(got by projects) project-id)
      =/  =test     (~(got by tests.project) test-id)
      =/  tid=@ta
        %+  rap  3
        :~  'ted-'
            project-id
            '-'
            ?^(name.test u.name.test (scot %ux test-id))
            '-'
            (scot %uw (sham eny.bowl))
        ==
      =/  =start-args:spider
        :-  ~
        :^  `tid  byk.bowl(r da+now.bowl)
          %ziggurat-test-run
        !>  ^-  (unit [test-steps (unit [@t @ux (list @p)])])
        `[steps.test `[project-id test-id ~[~nec ~bud]]]  :: TODO: remove hardcode and allow input of for-snapshot
      =/  w=wire  /test/[project-id]/(scot %ux test-id)/[tid]
      :_  state
      :+  :^  %pass  w  %agent
            [[our.bowl %spider] %watch /thread-result/[tid]]
        :^  %pass  w  %agent
        [[our.bowl %spider] %poke %spider-start !>(start-args)]
      ~
    ::
        %queue-test
      `state(test-queue (~(put to test-queue) [project.act id.act]))
    ::
        %add-and-queue-test
      ::  generate an id for the test
      =/  =project  (~(got by projects) project.act)
      =/  test-id=@ux  `@ux`(sham test-steps.act)
      =.  tests.project
        %+  ~(put by tests.project)  test-id
        [name.act test-steps.act ~]
      :-  [(make-project-update project.act project) ~]
      %=    state
          projects
        (~(put by projects) project.act project)
          test-queue
        (~(put to test-queue) [project:act test-id])
      ==
    ::
        %add-custom-step
      =/  addresses=^vase  !>(virtualnet-addresses)
      =/  compilation-result=(each ^vase @t)
        %^  compile-custom-step  tag.act
        custom-step-definition.act  addresses
      :-  ~
      %=  state
          custom-step-definitions
        %+  ~(put by custom-step-definitions)  tag.act
        [custom-step-definition.act compilation-result]
      ==
    ::
        %delete-custom-step
      :-  ~
      %=  state
          custom-step-definitions
        (~(del by custom-step-definitions) tag.act)
      ==
    ::
        %stop-pyro-ships
      :_  state(pyro-ships-ready ~)
      :~  [%give %fact [/pyro-done]~ [%noun !>(`*`**)]]
          [%give %kick [/pyro-done]~ ~]
      ==
    ::
        %start-pyro-ships
      =?  ships.act  ?=(~ ships.act)  ~[~nec ~bud]
      =/  wach=(list card:agent:gall)
        %+  turn  ships.act
        |=  who=ship
        :*  %pass  /ready/(scot %p who)  %agent
            [our.bowl %pyro]
            %watch  /ready/(scot %p who)
        ==
      =/  init=(list card:agent:gall)
        :_  ~
        :*  %pass  /  %agent
            [our.bowl %pyro]
            %poke  %aqua-events
            !>((turn ships.act |=(who=ship [%init-ship who])))
        ==
      :-  (weld wach init)
      %_    state
          pyro-ships-ready
        =|  r=(map ship ?)
        |-  ^-  (map ship ?)
        ?~  ships.act  r
        $(ships.act t.ships.act, r (~(put by r) i.ships.act %.n))      
      ==
    ::
        %deploy-contract  ::  TODO
      !!
    ::
        %publish-app  :: TODO
      ::  [%publish-app title=@t info=@t color=@ux image=@t version=[@ud @ud @ud] website=@t license=@t]
      ::  should assert that desk.bill contains only our agent name,
      ::  and that clause has been filled out at least partially,
      ::  then poke treaty agent with publish
      =/  project  (~(got by projects) project.act)
      =/  bill
        ;;  (list @tas)
        .^(* %cx /(scot %p our.bowl)/(scot %tas project.act)/(scot %da now.bowl)/desk/bill)
      ~|  "desk.bill should only contain our agent"
      ?>  =(bill ~[project.act])
      =/  docket-0
        :*  %1
            'Foo'
            'An app that does a thing.'
            0xf9.8e40
            [%glob `@tas`project.act [0v0 [%ames our.bowl]]]
            `'https://example.com/tile.svg'
            [0 0 1]
            'https://example.com'
            'MIT'
        ==
      =/  docket-task
        [%info `@tas`project.act %& [/desk/docket-0 %ins %docket-0 !>(docket-0)]~]
      :_  state
      :^    [%pass /save-wire %arvo %c docket-task]
          (make-compile project.act our.bowl)
        =-  [%pass /treaty-wire %agent [our.bowl %treaty] %poke -]
        [%alliance-update-0 !>([%add our.bowl `@tas`project.act])]
      ~
    ==
  ++  add-or-update-item
    |=  [project-id=@t =item:smart]
    ^-  (quip card _state)
    ?>  ?=(%& -.item)
    =,  p.item
    =/  =project  (~(got by projects) project-id)
    =/  noun-text  ;;(@t noun)
    =/  =data:smart
      =+  (text-to-zebra-noun noun-text smart-lib-vase)
      [id source holder town salt label -]
    =:  p.chain.project
      %+  put:big:engine  p.chain.project
      [id.data %&^data]
    ::
        noun-texts.project
      (~(put by noun-texts.project) id.data noun-text)
    ==
    :-  (make-project-update project-id project)^~
    state(projects (~(put by projects) project-id project))
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%test @ @ @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %kick      `this
        %poke-ack  `this
        %fact
      =*  project-name  i.t.wire
      =/  test-id=@ux   (slav %ux i.t.t.wire)
      =/  tid=@ta       i.t.t.t.wire
      ?+    p.cage.sign  (on-agent:def wire sign)
          %thread-fail
        ~&  ziggurat+thread-fail+project^test-id^tid
        `this
      ::
          %thread-done
        =+  !<(=test-results q.cage.sign)
        =/  =project  (~(got by projects) project-name)
        =/  =test     (~(got by tests.project) test-id)
        ~&  >  "%ziggurat: test done {(scow %ux test-id)}"
        =.  tests.project
          %+  ~(put by tests.project)  test-id
          test(results test-results)
        =/  cards=(list card)
          (make-project-update project-name project)^~
        =.  cards
          ?~  test-queue  cards
          %+  snoc  cards
          :^  %pass  /self-wire  %agent
          :^  [our dap]:bowl  %poke  %ziggurat-action
          !>([project-name %run-queue ~])
        :-  cards
        this(projects (~(put by projects) project-name project))
      ==
    ==
  ::
      [%ready @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      =/  who=ship  (slav %p i.t.wire)
      =.  pyro-ships-ready  (~(put by pyro-ships-ready) who %.y)
      =/  card=card:agent:gall
        :^  %pass  /ready/(scot %p who)  %agent
        [[our.bowl %pyro] %leave ~]
      ?~  test-queue                         [card^~ this]
      ?.  (~(all by pyro-ships-ready) same)  [card^~ this]
      :_  this
      :+  card
        :^  %pass  /self-wire  %agent
        :^  [our dap]:bowl  %poke  %ziggurat-action
        !>([%$ %run-queue ~])
      ~
    ==
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%merge-wire ~]
    ?.  ?=(%clay -.sign-arvo)  !!
    ?.  ?=(%mere -.+.sign-arvo)  !!
    ?:  -.p.+.sign-arvo
      ~&  >  "new desk successful"
      `this
    ~&  >>>  "failed to make new desk"
    `this
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  =,  format
  ?+    +.path  (on-peek:def path)
  ::
  ::  NOUNS
  ::
    ::   [%project-nock @ ~]
    :: ?~  project=(~(get by projects) (slav %t i.t.t.path))
    ::   ``noun+!>(~)
    :: ?>  ?=(%& -.u.project)
    :: ?~  compiled.p.u.project
    ::   ``noun+!>(~)
    :: ``noun+!>(compiled.p.u.project)
  ::
      [%custom-step-definitions ~]
    :^  ~  ~  %noun
    !>  ^-  ^custom-step-definitions
    %-  ~(run by custom-step-definitions)
    |=  [p=custom-step-definition q=custom-step-compiled]
    :-  p
    ?:  ?=(%| -.q)  q  [%& *vase]
  ::
      [%custom-step-compiled @ ~]
    =/  tag=@tas  `@tas`i.t.t.path
    ?~  def=(~(get by custom-step-definitions) tag)
      ~|("%ziggurat: did not find {<tag>} custom-step-definition in {<~(key by custom-step-definitions)>}" !!)
    ?:  ?=(%| -.q.u.def)  ::  TODO: do better
      ~|("%ziggurat: compilation of {<tag>} failed; please fix and try again" !!)
    ``noun+!>(`vase`p.q.u.def)
  ::
      [%test-queue ~]
    ``noun+!>(test-queue)
  ::
  ::  JSONS
  ::
      [%all-projects ~]
    =,  enjs
    =;  =json  ``json+!>(json)
    %-  pairs
    %+  murn  ~(tap by projects)
    |=  [name=@t =project]
    :-  ~  :-  name
    (project-to-json project)
  ::
      [%project-state @ ~]
    ?~  project=(~(get by projects) i.t.t.path)
      ``json+!>(~)
    =/  =json  (state-to-json p.chain.u.project noun-texts.u.project)
    ``json+!>(json)
  ::
    ::   [%project-tests @ ~]  :: TODO
    :: ?~  project=(~(get by projects) i.t.t.path)
    ::   ``json+!>(~)
    :: =/  =json  (tests-to-json tests.u.project)
    :: ``json+!>(json)
  ::
      [%project-user-files @ ~]
    ?~  project=(~(get by projects) i.t.t.path)
      ``json+!>(~)
    ``json+!>(`json`(user-files-to-json user-files.u.project))
  ::
      [%file-exists @ ^]
    =/  des=@ta    i.t.t.path
    =/  pat=^path  `^path`t.t.t.path
    =/  pre=^path  /(scot %p our.bowl)/(scot %tas des)/(scot %da now.bowl)
    ``json+!>(`json`[%b .^(? %cu (weld pre pat))])
  ::
  ::  APP-PROJECT JSON
  ::
      [%read-file @ ^]
    =/  des=@ta    i.t.t.path
    =/  pat=^path  `^path`t.t.t.path
    =/  pre  /(scot %p our.bowl)/(scot %tas des)/(scot %da now.bowl)
    =/  padh  (weld pre pat)
    =/  =mark  (rear pat)
    :^  ~  ~  %json  !>
    ^-  json
    :-  %s
    ?+    mark  =-  q.q.-
        !<(mime (.^(tube:clay %cc (weld pre /[mark]/mime)) .^(vase %cr padh)))
      %hoon    .^(@t %cx padh)
      %kelvin  (crip ~(ram re (cain !>(.^([@tas @ud] %cx padh)))))
      %ship    (crip ~(ram re (cain !>(.^(@p %cx padh)))))
      %bill    (crip ~(ram re (cain !>(.^((list @tas) %cx padh)))))
        %docket-0
      =-  (crip (spit-docket:mime:dock -))
      .^(docket:dock %cx padh)
    ==
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
