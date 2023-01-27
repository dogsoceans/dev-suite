::  development tool to see `update:zig`s that result from
::   pokes to `app/ziggurat.hoon`.
::   usage:
::   1. create project
::   2. run this thread to print out `update:zig`s for
::      that project
::   3. press Backspace to detatch thread
::   4. run whatever pokes/test-steps;
::      `update:zig`s will be output
::
/-  spider
/+  strandio,
    pyro=zig-pyro
::
=*  strand     strand:spider
=*  take-fact  take-fact:strandio
=*  watch-our  watch-our:strandio
::
=/  m  (strand ,vase)
=|  subject=vase
|^  ted
::
+$  arg-mold
  $:  project-name=@t
      iterations=@ud
  ==
::
++  ted
  ^-  thread:spider
  |=  args-vase=vase
  ^-  form:m
  =/  args  !<((unit arg-mold) args-vase)
  ?~  args
    ~&  >>>  "Usage:"
    ~&  >>>  "-zig!ziggurat-test-subscribe project-name=@t iterations=@ud"
    (pure:m !>(~))
  =*  project-name  project-name.u.args
  =*  iterations    iterations.u.args
  ::
  =|  counter=@ud
  =/  watch-wire=wire  /project/[project-name]
  ;<  ~  bind:m  (watch-our watch-wire %ziggurat watch-wire)
  |-
  ?:  =(iterations counter)  (pure:m !>(~))
  ;<  result=cage  bind:m  (take-fact watch-wire)
  ~&  %zts^p.result^(noah q.result)
  $(counter +(counter))
--
