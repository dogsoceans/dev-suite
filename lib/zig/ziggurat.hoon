/-  eng=zig-engine,
    ui=zig-indexer,
    zig=zig-ziggurat
/+  agentio,
    conq=zink-conq,
    dock=docket,
    smart=zig-sys-smart,
    ui-lib=zig-indexer,
    zink=zink-zink
|_  =bowl:gall
+*  this  .
    io    ~(. agentio bowl)
::
+$  card  card:agent:gall
::
::  utilities
::
++  make-project-error
  |=  [project-name=@t source=@tas level=@tas message=@t]
  ^-  card
  %-  fact:io  :_  ~[/project/[project-name]]
  (make-project-error-cage project-name source level message)
::
++  make-project-error-cage
  |=  [project-name=@t source=@tas level=@tas message=@t]
  ^-  cage
  ~&  %ziggurat^project-name^level^source^message
  :-  %ziggurat-project-update
  !>  ^-  project-update:zig
  [%error project-name source level message]
::
++  make-project-update
  |=  [project-name=@t =project:zig]
  ^-  card
  %-  fact:io  :_  ~[/project/[project-name]]
  :-  %ziggurat-project-update
  !>  ^-  project-update:zig
  [%update project-name (get-state project) project]
::
++  make-compile-contracts
  |=  [project-name=@t]
  ^-  card
  %-  ~(poke-self pass:io /self-wire)
  :-  %ziggurat-action
  !>(`action:zig`project-name^[%compile-contracts ~])
::
++  make-compile-contract
  |=  [project-name=@t file=path]
  ^-  card
  %-  ~(poke-self pass:io /self-wire)
  :-  %ziggurat-action
  !>(`action:zig`project-name^[%compile-contract file])
::
++  make-watch-for-file-changes
  |=  [project-name=@tas files=(list path)]
  ^-  card
  %-  ~(warp-our pass:io /clay/[project-name])
  :-  project-name
  :^  ~  %mult  da+now.bowl
  %-  ~(gas in *(set [care:clay path]))
  (turn files |=(p=path [%x p]))
::
++  make-read-desk
  |=  project-name=@t
  ^-  card
  %-  ~(poke-self pass:io /self-wire)
  :-  %ziggurat-action
  !>(`action:zig`project-name^[%read-desk ~])
::
++  make-save-jam
  |=  [project-name=@t file=path non=*]
  ^-  card
  ?>  ?=(%jam (rear file))
  %-  ~(arvo pass:io /save-wire)
  :+  %c  %info
  [`@tas`project-name %& [file %ins %noun !>(`@`(jam non))]~]
::
++  make-save-file
  |=  [project-name=@t file=path text=@t]
  ^-  card
  =/  file-type  (rear file)
  =/  mym=mime  :-  /application/x-urb-unknown
    %-  as-octt:mimes:html
    %+  rash  text
    (star ;~(pose (cold '\0a' (jest '\0d\0a')) next))
  %-  ~(arvo pass:io /save-wire)
  :-  %c
  :: =-  [%pass /save-wire %arvo %c -]
  :^  %info  `@tas`project-name  %&
  :_  ~  :+  file  %ins
  =*  reamed-text  q:(slap !>(~) (ream text))  ::  =* in case text unreamable
  ?+  file-type  [%mime !>(mym)] :: don't need to know mar if we have bytes :^)
    %hoon        [%hoon !>(text)]
    %ship        [%ship !>(;;(@p reamed-text))]
    %bill        [%bill !>(;;((list @tas) reamed-text))]
    %kelvin      [%kelvin !>(;;([@tas @ud] reamed-text))]
      %docket-0
    =-  [%docket-0 !>((need (from-clauses:mime:dock -)))]
    ;;((list clause:dock) reamed-text)
  ==
::
++  make-run-queue
  |=  project-name=@t
  ^-  card
  %-  ~(poke-self pass:io /self-wire)
  :-  %ziggurat-action
  !>(`action:zig`[project-name %run-queue ~])
::
++  make-test-steps-file
  |=  =test:zig
  ^-  @t
  %+  rap  3
  :~
  ::  imports
    %+  roll  ~(tap by test-surs.test)
    |=  [[face=@tas file=path] imports=@t]
    %+  rap  3
    :~  imports
        '/=  '
        face
        '  '
        (crip (noah !>(file)))
        '\0a'
    ==
  ::  infix
    '''
    ::
    |%
    ++  $
      ^-  test-steps:zig
      :~

    '''
  ::  test-steps
    %+  roll  steps.test
    |=  [=test-step:zig test-steps-text=@t]
    %+  rap  3
    :~  test-steps-text
        '  ::\0a'
        '    '
        (crip (noah !>(test-step)))
        '\0a'
    ==
  ::  suffix
    '''
      ==
    --

    '''
  ==
::
++  convert-contract-hoon-to-jam
  |=  contract-hoon-path=path
  ^-  (unit path)
  ?.  ?=([%con *] contract-hoon-path)  ~
  :-  ~
  %-  snoc
  :_  %jam
  %-  snip
  `path`(welp /con/compiled +.contract-hoon-path)
::
++  save-compiled-contracts
  |=  $:  project-name=@t
          build-results=(list [p=path q=build-result:zig])
      ==
  ^-  [(list card) (list [path @t])]
  =|  cards=(list card)
  =|  errors=(list [path @t])
  |-
  ?~  build-results      [cards errors]
  =*  contract-path       p.i.build-results
  =/  =build-result:zig   q.i.build-results
  =/  save-result=(each card [path @t])
    %^  save-compiled-contract  project-name  contract-path
    build-result
  ?:  ?=(%| -.save-result)
    %=  $
        build-results  t.build-results
        errors         [p.save-result errors]
    ==
  %=  $
      build-results  t.build-results
      cards          [p.save-result cards]
  ==
::
++  save-compiled-contract
  |=  $:  project-name=@t
          contract-path=path
          =build-result:zig
      ==
  ^-  (each card [path @t])
  ?:  ?=(%| -.build-result)
    [%| [contract-path p.build-result]]
  =/  contract-jam-path=path
    (need (convert-contract-hoon-to-jam contract-path))
  :-  %&
  %^  make-save-jam  project-name  contract-jam-path
  p.build-result
::
++  build-contract-projects
  |=  $:  smart-lib=vase
          desk=path
          to-compile=(set path)
      ==
  ^-  (list [path build-result:zig])
  %+  turn  ~(tap in to-compile)
  |=  p=path
  ~&  "building {<p>}..."
  [p (build-contract-project smart-lib desk p)]
::
++  build-contract-project
  |=  [smart-lib=vase desk=path to-compile=path]
  ^-  build-result:zig
  ::
  ::  adapted from compile-contract:conq
  ::  this wacky design is to get a somewhat more helpful error print
  ::
  |^
  =/  first  (mule |.(parse-main))
  ?:  ?=(%| -.first)
    :-  %|
    %-  get-formatted-error
    (snoc (scag 4 p.first) 'error parsing main:')
  =/  second  (mule |.((parse-libs -.p.first)))
  ?:  ?=(%| -.second)
    :-  %|
    %-  get-formatted-error
    (snoc (scag 3 p.second) 'error parsing library:')
  =/  third  (mule |.((build-libs p.second)))
  ?:  ?=(%| -.third)
    %|^(get-formatted-error (snoc (scag 1 p.third) 'error building libraries:'))
  =/  fourth  (mule |.((build-main +.p.third +.p.first)))
  ?:  ?=(%| -.fourth)
    %|^(get-formatted-error (snoc (scag 1 p.fourth) 'error building main:'))
  %&^[bat=p.fourth pay=-.p.third]
  ::
  ++  parse-main  ::  first
    ^-  [raw=(list [face=term =path]) contract-hoon=hoon]
    %-  parse-pile:conq
    (trip .^(@t %cx (welp desk to-compile)))
  ::
  ++  parse-libs  ::  second
    |=  raw=(list [face=term =path])
    ^-  (list hoon)
    %+  turn  raw
    |=  [face=term =path]
    ^-  hoon
    :+  %ktts  face
    +:(parse-pile:conq (trip .^(@t %cx (welp desk (welp path /hoon)))))
  ::
  ++  build-libs  ::  third
    |=  braw=(list hoon)
    ^-  [nok=* =vase]
    =/  libraries=hoon  [%clsg braw]
    :-  q:(~(mint ut p.smart-lib) %noun libraries)
    (slap smart-lib libraries)
  ::
  ++  build-main  ::  fourth
    |=  [payload=vase contract=hoon]
    ^-  *
    q:(~(mint ut p:(slop smart-lib payload)) %noun contract)
  --
::
++  get-formatted-error
  |=  e=(list tank)
  ^-  @t
  %-  crip
  %-  zing
  %+  turn  (flop e)
  |=  =tank
  (of-wall:format (wash [0 80] tank))
::
++  show-test-results
  |=  =test-results:zig
  ^-  shown-test-results:zig
  (turn test-results show-test-result)
::
++  show-test-result
  |=  =test-result:zig
  ^-  shown-test-result:zig
  %+  turn  test-result
  |=  [success=? expected=@t result=vase]
  =/  res-text=@t  (crip (noah result))
  :+  success  expected
  ?:  (lte 1.024 (met 3 res-text))  '<elided>'  ::  TODO: unhardcode
  res-text
::
++  noah-slap-ream
  |=  [number-sur-lines=@ud subject=vase payload=@t]
  ^-  tape
  =/  compilation-result
    (mule-slap-subject number-sur-lines subject payload)
  ?:  ?=(%| -.compilation-result)  (trip payload)
  (noah p.compilation-result)
::
++  mule-slap-subject
  |=  [number-sur-lines=@ud subject=vase payload=@t]
  ^-  (each vase @t)
  =/  compilation-result
    (mule |.((slap subject (ream payload))))
  ?:  ?=(%& -.compilation-result)  compilation-result
  =/  error-tanks=(list tank)  (scag 2 p.compilation-result)
  ?.  ?=([^ [%leaf ^] ~] error-tanks)
    ~&  p.compilation-result^(get-formatted-error p.compilation-result)
    :-  %|
    (get-formatted-error (scag 1 p.compilation-result))
  =/  [error-line-number=@ud col=@ud]
    (parse-error-line-col p.i.t.error-tanks)
  =/  real-line-number=@ud
    (dec (add number-sur-lines error-line-number))
  =/  modified-error-tanks=(list tank)
    ~[i.error-tanks [%leaf "\{{<real-line-number>} {<col>}}"]]
  :-  %|
  (get-formatted-error (scag 2 modified-error-tanks))
::
++  parse-error-line-col
  |=  line-col=tape
  ^-  [@ud @ud]
  =/  [=hair res=(unit [line-col=[@ud @ud] =nail])]
    %.  [[1 1] line-col]
    %-  full
    %+  ifix  [kel ker]
    ;~(plug dem:ag ;~(pfix ace dem:ag))
  ?^  res  line-col.u.res
  %-  mean  %-  flop
  =/  lyn  p.hair
  =/  col  q.hair
  :~  leaf+"syntax error"
      leaf+"\{{<lyn>} {<col>}}"
      leaf+(runt [(dec col) '-'] "^")
      leaf+(trip (snag (dec lyn) (to-wain:format (crip line-col))))
  ==
::
++  compile-and-call-buc
  |=  [number-sur-lines=@ud subject=vase payload=@t]
  ^-  (each vase @t)
  =/  hoon-compilation-result
    (mule-slap-subject number-sur-lines subject payload)
  ?:  ?=(%| -.hoon-compilation-result)
    hoon-compilation-result
  %^  mule-slap-subject  number-sur-lines
  p.hoon-compilation-result  '$'
::
++  make-recompile-custom-steps-cards
  |=  $:  project-name=@t
          test-id=@ux
          =custom-step-definitions:zig
      ==
  ^-  (list card)
  %+  turn  ~(tap by custom-step-definitions)
  |=  [tag=@tas [p=path *]]
  :^  %pass  /self-wire  %agent
  :^  [our dap]:bowl  %poke  %ziggurat-action
  !>  ^-  action:zig
  project-name^[%add-custom-step test-id tag p]
::
++  add-custom-step
  |=  [=test:zig project-name=@tas tag=@tas p=path]
  ^-  (unit test:zig)
  =/  file-scry-path=path
    :-  (scot %p our.bowl)
    (weld /[project-name]/(scot %da now.bowl) p)
  ?.  .^(? %cu file-scry-path)  ~
  =/  file-cord=@t  .^(@t %cx file-scry-path)
  =/  [surs=(list [face=@tas =path]) =hair]
    (parse-start-of-pile (trip file-cord))
  ?:  ?=(%| -.subject.test)
    ~|("%ziggurat: subject must compile from surs before adding custom step" !!)
  =/  compilation-result=(each vase @t)
    %^  compile-and-call-buc  p.hair  p.subject.test
    %-  of-wain:format
    (slag (dec p.hair) (to-wain:format file-cord))
  =.  custom-step-definitions.test
    %+  ~(put by custom-step-definitions.test)  tag
    [p compilation-result]
  ~?  ?=(%| -.compilation-result)
    %ziggurat^%custom-step-compilation-failed^p.compilation-result
  `test
::
++  get-state
  |=  =project:zig
  ^-  (map @ux chain:eng)
  =/  now-ta=@ta   (scot %da now.bowl)
  %-  ~(gas by *(map @ux chain:eng))
  %+  murn  ~(tap by town-sequencers.project)
  |=  [town-id=@ux who=@p]
  =/  who-ta=@ta   (scot %p who)
  =/  town-ta=@ta  (scot %ux town-id)
  =/  batch-order=update:ui
    %-  fall  :_  ~
    ;;  (unit update:ui)
    .^  noun
        %gx
        ;:  weld
          /(scot %p our.bowl)/pyro/[now-ta]/i/[who-ta]/gx
          /[who-ta]/indexer/[now-ta]/batch-order/[town-ta]
          /noun/noun
    ==  ==
  ?~  batch-order                     ~
  ?.  ?=(%batch-order -.batch-order)  ~
  ?~  batch-order.batch-order         ~
  =*  newest-batch  i.batch-order.batch-order
  =/  batch-chain=update:ui
    %-  fall  :_  ~
    ;;  (unit update:ui)
    .^  noun
        %gx
        ;:  weld
            /(scot %p our.bowl)/pyro/[now-ta]/i/[who-ta]/gx
            /[who-ta]/indexer/[now-ta]/newest/batch-chain
            /[town-ta]/(scot %ux newest-batch)/noun/noun
    ==  ==
  ?~  batch-chain                     ~
  ?.  ?=(%batch-chain -.batch-chain)  ~
  =/  chains=(list batch-chain-update-value:ui)
    ~(val by chains.batch-chain)
  ?.  =(1 (lent chains))              ~
  ?~  chains                          ~  ::  for compiler
  `[town-id chain.i.chains]
::  scry %ca or fetch from local cache
::
++  scry-or-cache-ca
  |=  [project-desk=@tas p=path =ca-scry-cache:zig]
  |^  ^-  (unit [vase ca-scry-cache:zig])
  =/  scry-path=path
    :-  (scot %p our.bowl)
    (weld /[project-desk]/(scot %da now.bowl) p)
  ?~  cache=(~(get by ca-scry-cache) [project-desk p])
    scry-and-cache-ca
  ?.  =(p.u.cache .^(@ %cz scry-path))  scry-and-cache-ca
  `[q.u.cache ca-scry-cache]
  ::
  ++  scry-and-cache-ca
    ^-  (unit [vase ca-scry-cache:zig])
    =/  scry-result
      %-  mule
      |.
      =/  scry-path=path
        :-  (scot %p our.bowl)
        (weld /[project-desk]/(scot %da now.bowl) p)
      =/  scry-vase=vase  .^(vase %ca scry-path)
      :-  scry-vase
      %+  ~(put by ca-scry-cache)  [project-desk p]
      [`@ux`.^(@ %cz scry-path) scry-vase]
    ?:  ?=(%& -.scry-result)  `p.scry-result
    ~&  %ziggurat^%scry-and-cache-ca-fail
    ~
  --
::
::  abbreviated parser from lib/zink/conq.hoon:
::   parse to end of imports, start of hoon.
::   used to find start of hoon for compilation and to find
::   proper line error number in case of error
::   (see +mule-slap-subject)
::
+$  small-start-of-pile  (list [face=term =path])
::
++  parse-start-of-pile
  |=  tex=tape
  ^-  [small-start-of-pile hair]
  =/  [=hair res=(unit [=small-start-of-pile =nail])]
    (start-of-pile-rule [1 1] tex)
  ?^  res  [small-start-of-pile.u.res hair]
  %-  mean  %-  flop
  =/  lyn  p.hair
  =/  col  q.hair
  :~  leaf+"syntax error"
      leaf+"\{{<lyn>} {<col>}}"
      leaf+(runt [(dec col) '-'] "^")
      leaf+(trip (snag (dec lyn) (to-wain:format (crip tex))))
  ==
::
++  start-of-pile-rule
  %+  ifix
    :_  gay
    ::  parse optional smart library import and ignore
    ;~(plug gay (punt ;~(plug fas lus gap taut-rule:conq gap)))
  ;~  plug
  ::  only accept /= imports for contract libraries
    %+  rune:conq  tis
    ;~(plug sym ;~(pfix gap stap))
  ==
::
::  files we delete from zig desk to make new gall desk
::
++  clean-desk
  |=  name=@t
  :~  [/app/indexer/hoon %del ~]
      [/app/rollup/hoon %del ~]
      [/app/sequencer/hoon %del ~]
      [/app/uqbar/hoon %del ~]
      [/app/wallet/hoon %del ~]
      [/app/ziggurat/hoon %del ~]
      [/gen/rollup/activate/hoon %del ~]
      [/gen/sequencer/batch/hoon %del ~]
      [/gen/sequencer/init/hoon %del ~]
      [/gen/uqbar/set-sources/hoon %del ~]
      [/gen/wallet/basic-tx/hoon %del ~]
      [/gen/build-hash-cache/hoon %del ~]
      [/gen/compile/hoon %del ~]
      [/gen/compose/hoon %del ~]
      [/gen/merk-profiling/hoon %del ~]
      [/gen/mk-smart/hoon %del ~]
      [/tests/contracts/fungible/hoon %del ~]
      [/tests/contracts/nft/hoon %del ~]
      [/tests/contracts/publish/hoon %del ~]
      [/tests/lib/merk/hoon %del ~]
      [/tests/lib/mill-2/hoon %del ~]
      [/tests/lib/mill/hoon %del ~]
      [/roadmap/md %del ~]
      [/readme/md %del ~]
      [/app/[name]/hoon %ins hoon+!>(simple-app)]
  ==
::
++  simple-app
  ^-  @t
  '''
  /+  default-agent, dbug
  |%
  +$  versioned-state
      $%  state-0
      ==
  +$  state-0  [%0 ~]
  --
  %-  agent:dbug
  =|  state-0
  =*  state  -
  ^-  agent:gall
  |_  =bowl:gall
  +*  this     .
      default   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init                     :: [(list card) this]
    `this(state [%0 ~])
  ++  on-save
    ^-  vase
    !>(state)
  ++  on-load                     :: |=(old-state=vase [(list card) this])
    on-load:default
  ++  on-poke   on-poke:default   :: |=(=cage [(list card) this])
  ++  on-watch  on-watch:default  :: |=(=path [(list card) this])
  ++  on-leave  on-leave:default  :: |=(=path [(list card) this])
  ++  on-peek   on-peek:default   :: |=(=path [(list card) this])
  ++  on-agent  on-agent:default  :: |=  [=wire =sign:agent:gall] 
                                  :: [(list card) this]
  ++  on-arvo   on-arvo:default   :: |=([=wire =sign-arvo] [(list card) this])
  ++  on-fail   on-fail:default   :: |=  [=term =tang] 
                                  :: %-  (slog leaf+"{<dap.bowl>}" >term< tang)
                                  :: [(list card) this]
  --
  '''
::
::  json
::
++  enjs
  =,  enjs:format
  |%
  ++  project
    |=  p=project:zig
    ^-  json
    %-  pairs
    :~  ['dir' (dir dir.p)]
        ['user_files' (dir ~(tap in user-files.p))]
        ['to_compile' (dir ~(tap in to-compile.p))]
        ['errors' (errors errors.p)]
        ['town_sequencers' (town-sequencers town-sequencers.p)]
        ['tests' (tests tests.p)]
        ['dbug_dashboards' (dbug-dashboards dbug-dashboards.p)]
    ==
  ::
  ++  state
    |=  state=(map @ux chain:eng)
    ^-  json
    %-  pairs
    %+  turn  ~(tap by state)
    |=  [town-id=@ux =chain:eng]
    [(scot %ux town-id) (chain:enjs:ui-lib chain)]
  ::
  ++  tests
    |=  =tests:zig
    ^-  json
    %-  pairs
    %+  turn  ~(tap by tests)
    |=  [id=@ux t=test:zig]
    [(scot %ux id) (test t)]
  ::
  ++  test
    |=  =test:zig
    ^-  json
    %-  pairs
    :~  ['name' %s ?~(name.test '' u.name.test)]
        ['test-steps-file' (path test-steps-file.test)]
        ['test-surs' (test-surs test-surs.test)]
        ['subject' %s ?:(?=(%& -.subject.test) '' p.subject.test)]
        ['custom-step-definitions' (custom-step-definitions custom-step-definitions.test)]
        ['steps' (test-steps steps.test)]
        ['results' (test-results results.test)]
    ==
  ::
  ++  test-surs
    |=  =test-surs:zig
    ^-  json
    %-  pairs
    %+  turn  ~(tap by test-surs)
    |=  [face=@tas p=^path]
    [face (path p)]
  ::
  ++  dir
    |=  dir=(list ^path)
    ^-  json
    :-  %a
    %+  turn  dir
    |=(p=^path (path p))
  ::
  ++  errors
    |=  errors=(map ^path @t)
    ^-  json
    %-  pairs
    %+  turn  ~(tap by errors)
    |=  [p=^path error=@t]
    [(crip (noah !>(`^path`p))) %s error]
  ::
  ++  custom-step-definitions
    |=  =custom-step-definitions:zig
    ^-  json
    %-  pairs
    %+  turn  ~(tap by custom-step-definitions)
    |=  [id=@tas p=^path com=custom-step-compiled:zig]
    :-  id
    %-  pairs
    :+  ['path' (path p)]
      ['custom-step-compiled' (custom-step-compiled com)]
    ~
  ::
  ++  custom-step-compiled
    |=  =custom-step-compiled:zig
    ^-  json
    %-  pairs
    :+  ['compiled-successfully' %b ?=(%& -.custom-step-compiled)]
      ['compile-error' %s ?:(?=(%& -.custom-step-compiled) '' p.custom-step-compiled)]
    ~
  ::
  ++  town-sequencers
    |=  town-sequencers=(map @ux @p)
    ^-  json
    %-  pairs
    %+  turn  ~(tap by town-sequencers)
    |=  [town-id=@ux who=@p]
    [(scot %ux town-id) %s (scot %p who)]
  ::
  ++  test-steps
    |=  =test-steps:zig
    ^-  json
    :-  %a
    %+  turn  test-steps
    |=([ts=test-step:zig] (test-step ts))
  ::
  ++  test-step
    |=  =test-step:zig
    ^-  json
    ?:  ?=(?(%dojo %poke %subscribe %custom-write) -.test-step)
      (test-write-step test-step)
    ?>  ?=(?(%scry %read-subscription %wait %custom-read) -.test-step)
    (test-read-step test-step)
  ::
  ++  test-write-step
    |=  test-step=test-write-step:zig
    ^-  json
    %+  frond  -.test-step
    ?-    -.test-step
        %dojo
      %-  pairs
      :+  ['payload' (dojo-payload payload.test-step)]
        ['expected' (write-expected expected.test-step)]
      ~
    ::
        %poke
      %-  pairs
      :+  ['payload' (poke-payload payload.test-step)]
        ['expected' (write-expected expected.test-step)]
      ~
    ::
        %subscribe
      %-  pairs
      :+  ['payload' (sub-payload payload.test-step)]
        ['expected' (write-expected expected.test-step)]
      ~
    ::
        %custom-write
      %+  frond  tag.test-step
      %-  pairs
      :+  ['payload' %s payload.test-step]
        ['expected' (write-expected expected.test-step)]
      ~
    ==
  ::
  ++  test-read-step
    |=  test-step=test-read-step:zig
    ^-  json
    %+  frond  -.test-step
    ?-    -.test-step
        %scry
      %-  pairs
      :+  ['payload' (scry-payload payload.test-step)]
        ['expected' %s expected.test-step]
      ~
    ::
        %dbug
      %-  pairs
      :+  ['payload' (dbug-payload payload.test-step)]
        ['expected' %s expected.test-step]
      ~
    ::
        %read-subscription
      %-  pairs
      :+  ['payload' (sub-payload payload.test-step)]
        ['expected' %s expected.test-step]
      ~
    ::
        %wait
      (frond 'until' [%s (scot %dr until.test-step)])
    ::
        %custom-read
      %+  frond  tag.test-step
      %-  pairs
      :+  ['payload' %s payload.test-step]
        ['expected' %s expected.test-step]
      ~
    ==
  ::
  ++  scry-payload
    |=  payload=scry-payload:zig
    ^-  json
    %-  pairs
    :~  ['who' %s (scot %p who.payload)]
        ['mold-name' %s mold-name.payload]
        ['care' %s care.payload]
        ['app' %s app.payload]
        ['path' (path path.payload)]
    ==
  ::
  ++  dbug-payload
    |=  payload=dbug-payload:zig
    ^-  json
    %-  pairs
    :^    ['who' %s (scot %p who.payload)]
        ['mold-name' %s mold-name.payload]
      ['app' %s app.payload]
    ~
  ::
  ++  poke-payload
    |=  payload=poke-payload:zig
    ^-  json
    %-  pairs
    :~  ['who' %s (scot %p who.payload)]
        ['to' %s (scot %p to.payload)]
        ['app' %s app.payload]
        ['mark' %s mark.payload]
        ['payload' %s payload.payload]
    ==
  ::
  ++  dojo-payload
    |=  payload=dojo-payload:zig
    ^-  json
    %-  pairs
    :+  ['who' %s (scot %p who.payload)]
      ['payload' %s payload.payload]
    ~
  ::
  ++  sub-payload
    |=  payload=sub-payload:zig
    ^-  json
    %-  pairs
    :~  ['who' %s (scot %p who.payload)]
        ['to' %s (scot %p to.payload)]
        ['app' %s app.payload]
        ['path' (path path.payload)]
    ==
  ::
  ++  write-expected
    |=  test-read-steps=(list test-read-step:zig)
    ^-  json
    :-  %a
    %+  turn  test-read-steps
    |=  [trs=test-read-step:zig]
    (test-read-step trs)
  ::
  ++  test-results
    |=  =test-results:zig
    ^-  json
    :-  %a
    %+  turn  test-results
    |=([tr=test-result:zig] (test-result tr))
  ::
  ++  test-result
    |=  =test-result:zig
    ^-  json
    :-  %a
    %+  turn  test-result
    |=  [success=? expected=@t result=vase]
    %-  pairs
    :^    ['success' %b success]
        ['expected' %s expected]
      ['result' %s (crip (noah result))]
    ~
  ::
  ++  dbug-dashboards
    |=  dashboards=(map @tas dbug-dashboard:zig)
    ^-  json
    %-  pairs
    %+  turn  ~(tap by dashboards)
    |=  [app=@tas d=dbug-dashboard:zig]
    [app (dbug-dashboard d)]
  ::
  ++  dbug-dashboard
    |=  d=dbug-dashboard:zig
    ^-  json
    %-  pairs
    :~  [%sur (path sur.d)]
        [%mold-name %s mold-name.d]
        [%mar (path mar.d)]
        [%did-mold-compile %b ?=(%& mold.d)]
        [%did-mar-tube-compile %b ?=(^ mar-tube.d)]
    ==
  ::
  ++  single-string-object
    |=  [key=@t error=^tape]
    ^-  json
    (frond key (tape error))
  --
++  dejs
  =,  dejs:format
  |%
  ++  uber-action
    ^-  $-(json action:zig)
    %-  ot
    :~  [%project so]
        [%action action]
    ==
  ::
  ++  action
    %-  of
    :~  [%new-project ul]
        [%delete-project ul]
    ::
        [%save-file (ot ~[[%file pa] [%text so]])]
        [%delete-file (ot ~[[%file pa]])]
    ::
        [%set-virtualnet-address (ot ~[[%who (se %p)] [%address (se %ux)]])]
    ::
        [%register-contract-for-compilation (ot ~[[%file pa]])]
        [%deploy-contract deploy]
    ::
        [%compile-contracts ul]
        [%compile-contract (ot ~[[%path pa]])]
        [%read-desk ul]
    ::
        [%add-test add-test]
        [%add-and-run-test add-test]
        [%add-and-queue-test add-test]
        [%save-test-to-file (ot ~[[%id (se %ux)] [%path pa]])]
    ::
        [%add-test-file add-test-file]
        [%add-and-run-test-file add-test-file]
        [%add-and-queue-test-file add-test-file]
    ::
        [%delete-test (ot ~[[%id (se %ux)]])]
        [%run-test (ot ~[[%id (se %ux)]])]
        [%run-queue ul]
        [%clear-queue ul]
        [%queue-test (ot ~[[%id (se %ux)]])]
    ::
        [%add-custom-step add-custom-step]
        [%delete-custom-step (ot ~[[%test-id (se %ux)] [%tag (se %tas)]])]
    ::
        [%add-app-to-dashboard add-app-to-dashboard]
        [%delete-app-from-dashboard (ot ~[[%app (se %tas)]])]
    ::
        [%add-town-sequencer (ot ~[[%town-id (se %ux)] [%who (se %p)]])]
        [%delete-town-sequencer (ot ~[[%town-id (se %ux)]])]
    ::
        [%stop-pyro-ships ul]
        [%start-pyro-ships (ot ~[[%ships (ar (se %p))]])]
        [%start-pyro-snap (ot ~[[%snap pa]])]
    ::
        [%publish-app docket]
        [%add-user-file (ot ~[[%file pa]])]
        [%delete-user-file (ot ~[[%file pa]])]
    ==
  ::
  ++  docket
    ^-  $-(json [@t @t @ux @t [@ud @ud @ud] @t @t])
    %-  ot
    :~  [%title so]
        [%info so]
        [%color (se %ux)]
        [%image so]
        [%version (at ~[ni ni ni])]
        [%website so]
        [%license so]
    ==
  ::
  ++  deploy
    ^-  $-(json [town-id=@ux contract-jam=path])
    %-  ot
    :~  [%town-id (se %ux)]
        [%path pa]
    ==
  ::
  ++  add-test
    ^-  $-(json [(unit @t) test-surs:zig test-steps:zig])
    %-  ot
    :^    [%name so:dejs-soft:format]
        [%test-surs (om pa)]
      [%test-steps (ar test-step)]
    ~
  ::
  ++  add-test-file
    ^-  $-(json [name=(unit @t) test-steps-path=path])
    %-  ot
    :+  [%name so:dejs-soft:format]
      [%path pa]
    ~
  ::
  ++  test-step
    ^-  $-(json test-step:zig)
    %-  of
    (welp test-read-step-inner test-write-step-inner)
  ::
  ++  test-read-step
    ^-  $-(json test-read-step:zig)
    (of test-read-step-inner)
  ::
  ++  test-read-step-inner
    :~  [%scry (ot ~[[%payload scry-payload] [%expected so]])]
        [%dbug (ot ~[[%payload dbug-payload] [%expected so]])]
        [%read-subscription (ot ~[[%payload read-sub-payload] [%expected so]])]
        [%wait (ot ~[[%until (se %dr)]])]
        [%custom-read (ot ~[[%tag (se %tas)] [%payload so] [%expected so]])]
    ==
  ::
  ++  scry-payload
    ^-  $-(json scry-payload:zig)
    %-  ot
    :~  [%who (se %p)]
        [%mold-name so]
        [%care (se %tas)]
        [%app (se %tas)]
        [%path pa]
    ==
  ::
  ++  dbug-payload
    ^-  $-(json dbug-payload:zig)
    %-  ot
    :^    [%who (se %p)]
        [%mold-name so]
      [%app (se %tas)]
    ~
  ::
  ++  read-sub-payload
    ^-  $-(json read-sub-payload:zig)
    %-  ot
    :~  [%who (se %p)]
        [%to (se %p)]
        [%app (se %tas)]
        [%path pa]
    ==
  ::
  ++  test-write-step
    ^-  $-(json test-write-step:zig)
    (of test-write-step-inner)
  ::
  ++  test-write-step-inner
    :~  [%dojo (ot ~[[%payload dojo-payload] [%expected (ar test-read-step)]])]
        [%poke (ot ~[[%payload poke-payload] [%expected (ar test-read-step)]])]
        [%subscribe (ot ~[[%payload subscribe-payload] [%expected (ar test-read-step)]])]
        [%custom-write (ot ~[[%tag (se %tas)] [%payload so] [%expected (ar test-read-step)]])]
    ==
  ::
  ++  dojo-payload
    ^-  $-(json dojo-payload:zig)
    %-  ot
    :+  [%who (se %p)]
      [%payload so]
    ~
  ::
  ++  poke-payload
    ^-  $-(json poke-payload:zig)
    %-  ot
    :~  [%who (se %p)]
        [%to (se %p)]
        [%app (se %tas)]
        [%mark (se %tas)]
        [%payload so]
    ==
  ::
  ++  subscribe-payload
    ^-  $-(json sub-payload:zig)
    %-  ot
    :~  [%who (se %p)]
        [%to (se %p)]
        [%app (se %tas)]
        [%path pa]
    ==
  ::
  ++  add-custom-step
    ^-  $-(json [test-id=@ux tag=@tas custom-step-file=path])
    %-  ot
    :^    [%test-id (se %ux)]
        [%tag (se %tas)]
      [%path pa]
    ~
  ::
  ++  add-app-to-dashboard
    ^-  $-(json [app=@tas sur=path mold-name=@t mar=path])
    %-  ot
    :~  [%app (se %tas)]
        [%sur pa]
        [%mold-name so]
        [%mar pa]
    ==
  --
--
