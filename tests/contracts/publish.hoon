::
::  Tests for publish.hoon
::
/-  zink
/+  *test, smart=zig-sys-smart, *sequencer, merk
/*  smart-lib-noun    %noun  /lib/zig/compiled/smart-lib/noun
/*  zink-cax-noun     %noun  /lib/zig/compiled/hash-cache/noun
/*  publish-contract  %noun  /lib/zig/compiled/publish/noun
|%
::
::  constants / dummy info for mill
::
++  big  (bi:merk id:smart grain:smart)  ::  merkle engine for granary
++  pig  (bi:merk id:smart @ud)          ::                for populace
++  town-id   0x0
++  fake-sig  [0 0 0]
++  mil
  %~  mill  mill
  :+    ;;(vase (cue q.q.smart-lib-noun))
    ;;((map * @) (cue q.q.zink-cax-noun))
  %.y
::
+$  mill-result
  [fee=@ud =land burned=granary =errorcode:smart hits=(list hints:zink) =crow:smart]
::
::  fake data
::
++  miller  ^-  caller:smart
  [0x24c.23b9.8535.cd5a.0645.5486.69fb.afbf.095e.fcc0 1 0x0]  ::  zigs account not used
++  holder-1  0xd387.95ec.b77f.b88e.c577.6c20.d470.d13c.8d53.2169
++  caller-1  ^-  caller:smart  [holder-1 1 id.p:account-1:zigs]
::
++  zigs
  |%
  ++  account-1
    ^-  grain:smart
    :*  %&
        `@`'zigs'
        %account
        [300.000.000 ~ `@ux`'zigs-metadata']
        (fry-rice:smart zigs-wheat-id:smart holder-1 town-id `@`'zigs')
        zigs-wheat-id:smart
        holder-1
        town-id
    ==
  --
::
++  trivial-nok  ^-  [bat=* pay=*]
  [bat=[8 [1 0 [0 0] 0 0] [1 [8 [1 0] [1 [1 0] 1 0] 0 1] 8 [1 0] [1 1 0 0 0 0 0] 0 1] 0 1] pay=[1 0]]
++  trivial-nok-upgrade  ^-  [bat=* pay=*]
  [bat=[8 [1 0 [0 0] 0 0] [1 [8 [1 0] [1 [1 0] 1 0] 0 1] 8 [1 0] [1 8 [8 [9 2.398 0 16.127] 9 2 10 [6 7 [0 3] 1 100] 0 2] 1 0 0 0 0 0] 0 1] 0 1] pay=[1 0]]
::
++  upgradable-id
  (fry-wheat:smart id.p:publish-wheat town-id `trivial-nok)
++  upgradable
  ^-  grain:smart
  :*  %|
        `trivial-nok
        ~
        ~
        upgradable-id
        id.p:publish-wheat
        id:caller-1
        town-id
    ==
::
++  publish-wheat
  ^-  grain:smart
  =/  cont  ;;([bat=* pay=*] (cue q.q.publish-contract))
  =/  interface=lumps:smart  ~
  =/  types=lumps:smart  ~
  :*  %|
      `cont
      interface
      types
      0xdada.dada  ::  id
      0xdada.dada  ::  lord
      0xdada.dada  ::  holder
      town-id
  ==
::
++  fake-granary
  ^-  granary
  %+  gas:big  *(merk:merk id:smart grain:smart)
  :~  [id.p:publish-wheat publish-wheat]
      [id.p:upgradable upgradable]
      [id.p:account-1:zigs account-1:zigs]
  ==
++  fake-populace
  ^-  populace
  %+  gas:pig  *(merk:merk id:smart @ud)
  ~[[id:caller-1 0]]
++  fake-land
  ^-  land
  [fake-granary fake-populace]
::
::  begin tests
::
++  test-mill-trivial-deploy
  =/  =yolk:smart  [%deploy %.y trivial-nok ~ ~ ~]
  =/  shel=shell:smart
    [caller-1 ~ id.p:publish-wheat 1 1.000.000 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id 1)
      [(del:big fake-granary upgradable-id) fake-populace]
    `egg:smart`[fake-sig shel yolk]
  ::
  ~&  >  "fee: {<fee.res>}"
  ~&  p.land.res
  ;:  weld
  ::  assert that our call went through
    %+  expect-eq
    !>(%0)  !>(errorcode.res)
  ::  assert new contract grain was created properly
    %+  expect-eq
      !>(upgradable)
    !>((got:big p.land.res upgradable-id))
  ==
::
++  test-mill-trivial-upgrade
  =/  =yolk:smart  [%upgrade upgradable-id trivial-nok-upgrade]
  =/  shel=shell:smart
    [caller-1 ~ id.p:publish-wheat 1 1.000.000 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id 1)
      fake-land
    `egg:smart`[fake-sig shel yolk]
  ::
  =/  new-wheat
    ^-  grain:smart
    :*  %|
        `trivial-nok-upgrade
        ~
        ~
        upgradable-id
        id.p:publish-wheat
        id:caller-1
        town-id
    ==
  ~&  >  "fee: {<fee.res>}"
  ~&  p.land.res
  ;:  weld
  ::  assert that our call went through
    %+  expect-eq
    !>(%0)  !>(errorcode.res)
  ::  assert new contract grain was created properly
    %+  expect-eq
      !>(new-wheat)
    !>((got:big p.land.res upgradable-id))
  ==
--