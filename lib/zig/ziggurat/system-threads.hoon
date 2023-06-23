/-  linedb,
    pyro,
    spider,
    zig=zig-ziggurat
/+  strandio,
    pyro-lib=pyro,
    zig-lib=zig-ziggurat,
    zig-threads=zig-ziggurat-threads
::
=*  strand          strand:spider
=*  get-bowl        get-bowl:strandio
=*  get-time        get-time:strandio
=*  leave-our       leave-our:strandio
=*  poke-our        poke-our:strandio
=*  scry            scry:strandio
=*  send-raw-card   send-raw-card:strandio
=*  sleep           sleep:strandio
=*  take-fact       take-fact:strandio
=*  take-poke       take-poke:strandio
=*  warp            warp:strandio
=*  watch-our       watch-our:strandio
::
|_  [project-name=@t desk-name=@tas]
++  send-long-operation-update
  |=  =long-operation-info:zig
  =/  m  (strand ,vase)
  ~&  %z^%slou^%start^long-operation-info
  ^-  form:m
  ?~  long-operation-info  (pure:m !>(~))
  ;<  ~  bind:m
    (watch-our /update-done %ziggurat /project)
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  ~
    :-  %send-update
    :^  %long-operation-current-step
      [project-name desk-name %send-long-operation-update ~]
    [%& u.long-operation-info]  ~
  |-
  ;<  update-done=cage  bind:m  (take-fact /update-done)
  ?.  ?=(%ziggurat-update p.update-done)
    ~&  %ziggurat^%send-long-operation-update^%unexpected-mark
    $
  =+  !<(=update:zig q.update-done)
  ?.  ?=(%long-operation-current-step -.update)
    ~&  %ziggurat^%send-long-operation-update^%unexpected-update
    $
  ?.  ?=(%& -.payload.update)
    ~&  %ziggurat^%send-long-operation-update^%unexpected-error
    !!
  ?.  =(u.long-operation-info p.payload.update)
    ~&  %ziggurat^%send-long-operation-update^%unexpected-content
    !!
  ;<  ~  bind:m  (leave-our /update-done %ziggurat)
  ;<  ~  bind:m  (sleep ~s2)
  ~&  %z^%slou^%done^long-operation-info
  (pure:m !>(~))
::
++  skip-queue
  =/  m  (strand ,vase)
  |=  [request-id=(unit @t) skipper=_*form:m]
  ^-  form:m
  ;<  starting-state=state-1:zig  bind:m
    get-state:zig-threads
  =/  existing-queue=thread-queue:zig
    thread-queue.starting-state
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  request-id
    :-  %set-ziggurat-state
    starting-state(thread-queue ~)
  ;<  ~  bind:m
    (watch-our /queue-done %ziggurat /project)
  ;<  empty-vase=vase  bind:m  skipper
  ;<  ~  bind:m
    %+  poke-our:strandio  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  request-id
    [%run-queue ~]
  |-
  ;<  update-done=cage  bind:m
    (take-fact:strandio /queue-done)
  ?.  ?=(%ziggurat-update p.update-done)  $
  =+  !<(=update:zig q.update-done)
  ?.  ?=(%status -.update)                $
  ?.  ?=(%& -.payload.update)             $
  ?.  ?=([%ready ~] p.payload.update)     $
  ;<  ~  bind:m
    (leave-our:strandio /queue-done %ziggurat)
  ;<  newest-state=state-1:zig  bind:m
    get-state:zig-threads
  ;<  ~  bind:m
    %+  poke-our:strandio  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  request-id
    :-  %set-ziggurat-state
    newest-state(thread-queue existing-queue)
  (pure:m !>(~))
::
++  run-and-wait-on-linedb-action
  |=  [=action:linedb watch-path=path number-facts=@ud]
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  %z^%rawola^%0^watch-path
  ;<  ~  bind:m
    %^  watch-our  /done  %linedb
    [%branch-updates watch-path]
  ~&  %z^%rawola^%1
  ;<  ~  bind:m
    %+  poke-our  %linedb
    [%linedb-action !>(`action:linedb`action)]
  ~&  %z^%rawola^%2
  ;<  empty-vase=vase  bind:m
    |-
    ~&  %z^%rawola^%3^number-facts
    ?:  =(0 number-facts)  (pure:m !>(~))
    ;<  fact=cage  bind:m  (take-fact /done)
    ?.  ?=(%linedb-update p.fact)  !!
    $(number-facts (dec number-facts))
  ~&  %z^%rawola^%4
  ;<  ~  bind:m  (leave-our /done %linedb)
  (pure:m !>(~))
::
++  fetch-repo
  |=  $:  repo-host=@p
          repo-name=@tas
          branch-name=@tas
          =long-operation-info:zig
          followup-action=(unit vase)
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  empty-vase=vase  bind:m
    (send-long-operation-update long-operation-info)
  ;<  =bowl:strand  bind:m  get-bowl
  =*  branch-path=path
    /(scot %p repo-host)/[repo-name]/[branch-name]
  ~&  %z^%fr^branch-path
  ?:  =(our.bowl repo-host)
    ;<  ~  bind:m
      %+  poke-our  %linedb
      :-  %linedb-action
      !>  ^-  action:linedb
      [%fetch repo-host repo-name branch-name]
    ~&  %z^%fr^%prs
    ;<  ~  bind:m  (sleep ~s1)
    ~&  %z^%fr^%ps
    ~&  %z^%fr^%self-fetch
    ?~  followup-action  (pure:m !>(~))
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      [%ziggurat-action u.followup-action]
    (pure:m !>(~))
  ;<  empty-vase=vase  bind:m
    =*  repo-local-copy
      .^  *
          %gx
          :^  (scot %p our.bowl)  %linedb
          (scot %da now.bowl)  (snoc branch-path %noun)
      ==
    ~&  %z^%fr^branch-path^%have-local-copy^?=(^ repo-local-copy)
    ?:  ?=(^ repo-local-copy)
      ::  already have repo
      (pure:m !>(~))
    ;<  update-vase=vase  bind:m
      %-  run-and-wait-on-linedb-action  :_  [branch-path 2]
      [%fetch repo-host repo-name branch-name]
    (pure:m !>(~))
  ~&  %z^%fr^%3
  ;<  empty-vase=vase  bind:m
    ;<  =bowl:strand  bind:m  get-bowl
    =*  our-repo-local-copy
      .^  *
          %gx
          :^  (scot %p our.bowl)  %linedb
            (scot %da now.bowl)
          /(scot %p our.bowl)/[repo-name]/[branch-name]/noun
      ==
    ?:  ?=(^ our-repo-local-copy)
      ;<  ~  bind:m
        %+  poke-our  %linedb
        :-  %linedb-action
        !>  ^-  action:linedb
        [%merge repo-name branch-name repo-host branch-name]
      ;<  ~  bind:m  (sleep ~s5)  ::  TODO: tune
      ~&  %z^%fr^%37
      (pure:m !>(~))
    ~&  %z^%fr^%35
    ;<  ~  bind:m
      %+  poke-our  %linedb
      :-  %linedb-action
      !>  ^-  action:linedb
      [%branch repo-host repo-name branch-name branch-name]
    ~&  %z^%fr^%36
    ~&  %z^%fr^%prs
    ;<  ~  bind:m  (sleep ~s1)
    ~&  %z^%fr^%ps
    ;<  update-vase=vase  bind:m
      %^  run-and-wait-on-linedb-action
        [%fetch our.bowl repo-name branch-name]
      [(scot %p our.bowl) +.branch-path]  1
    (pure:m !>(~))
  ~&  %z^%fr^%4
  ?~  followup-action  (pure:m !>(~))
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    [%ziggurat-action u.followup-action]
  ~&  %z^%fr^%5
  (pure:m !>(~))
::
++  branch-if-non-head
  |=  [most-recently-seen-commit=@ux =repo-info:zig]
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  %z^%binh^%0
  ;<  =bowl:strand  bind:m  get-bowl
  =*  repo-host    repo-host.repo-info
  =*  repo-name    repo-name.repo-info
  =*  branch-name  branch-name.repo-info
  =/  commit-hash=(unit @ux)  commit-hash.repo-info
  ~&  %z^%binh^%1
  ?~  commit-hash  (pure:m !>(repo-info))
  ?:  =(most-recently-seen-commit u.commit-hash)
    ::  we are committing to master/head, so maintain it
    (pure:m !>([repo-host repo-name branch-name ~]))
  =/  new-branch-name=@tas
    =/  repos=(set [@p path])
      %-  ~(gas in *(set [@p path]))
      .^  (list [@p path])
          %gx
          :^  (scot %p our.bowl)  %linedb
          (scot %da now.bowl)  /noun
      ==
    =/  index=@ud  0
    |-
    =*  proposed-branch-name=@tas
      (cat 3 'branch-' (scot %ud index))
    ?:  %-  ~(has in repos)
        [our.bowl /[repo-name]/[proposed-branch-name]]
      $(index +(index))
    proposed-branch-name
  ~&  %z^%binh^%2
  ;<  ~  bind:m
    %+  poke-our  %linedb
    :-  %linedb-action
    !>  ^-  action:linedb
    [%branch repo-host repo-name branch-name new-branch-name]
  ;<  ~  bind:m  (sleep ~s1)  ::  TODO: necessary?
  ~&  %z^%binh^%3
  ;<  ~  bind:m
    %+  poke-our  %linedb
    :-  %linedb-action
    !>  ^-  action:linedb
    [%reset repo-name new-branch-name u.commit-hash]
  ;<  ~  bind:m  (sleep ~s1)  ::  TODO: necessary?
  ~&  %z^%binh^%4
  =.  repo-info
    repo-info(branch-name new-branch-name, commit-hash ~)
  ~&  %z^%binh^%5
  ;<  empty-vase=vase  bind:m
    (fetch-repo our.bowl repo-name new-branch-name ~ ~)
  ~&  %z^%binh^%6
  (pure:m !>(repo-info))
:: ::
:: ++  modify-file
::   |=  $:  file-path=path
::           file-contents=(unit @)  ::  ~ -> delet
::           maybe-repo-info=(unit repo-info:zig)
::       ==
::   =/  m  (strand ,vase)
::   ^-  form:m
::   ~&  %z^%sf^%0^[file-path ?=(^ file-contents) maybe-repo-info]
::   ;<  state=state-1:zig  bind:m  get-state:zig-threads
::   ;<  =bowl:strand  bind:m  get-bowl
::   =/  old-project=project:zig
::     (~(got by projects.state) project-name)
::   =/  =desk:zig  (got-desk:zig-lib old-project desk-name)
::   =/  old-repo-info=repo-info:zig  repo-info.desk
::   ~&  %z^%sf^%1^old-repo-info
::   ;<  repo-info-vase=vase  bind:m
::     %+  branch-if-non-head  most-recently-seen-commit.desk
::     ?~(maybe-repo-info repo-info.desk u.maybe-repo-info)
::   =+  !<(=repo-info:zig repo-info-vase)
::   ~&  %z^%sf^%3^repo-info
::   =/  new-project=project:zig
::     %^  put-desk:zig-lib  old-project  desk-name
::     desk(repo-info repo-info)
::   ;<  ~  bind:m
::     %+  poke-our  %ziggurat
::     :-  %ziggurat-action
::     !>  ^-  action:zig
::     :^  project-name  desk-name  ~
::     :-  %set-ziggurat-state
::     %=  state
::         projects
::       (~(put by projects.state) project-name new-project)
::     ==
::   ;<  empty-vase=vase  bind:m
::     =/  cages=(list cage)
::       %+  update-linedb-watches-cages:zig-lib
::         :-  project-name
::         (project-to-repo-infos:zig-lib old-project)
::       :-  project-name
::       (project-to-repo-infos:zig-lib new-project)
::     |-
::     ?~  cages  (pure:m !>(~))
::     ;<  ~  bind:m  (poke-our %ziggurat i.cages)
::     $(cages t.cages)
::   ;<  ~  bind:m  (sleep ~s1)  ::  TODO: necessary?
::   =*  repo-host    (scot %p repo-host.repo-info)
::   =*  repo-name    repo-name.repo-info
::   =*  branch-name  branch-name.repo-info
::   =*  commit-hash  commit-hash.repo-info
::   =*  commit=@ta
::     ?~  commit-hash  %head  (scot %uv u.commit-hash)
::   ;<  snap=(map path wain)  bind:m
::     %+  scry  (map path wain)
::     :+  %gx  %linedb
::     /[repo-host]/[repo-name]/[branch-name]/[commit]/noun
::   ;<  ~  bind:m
::     %+  poke-our  %linedb
::     :-  %linedb-action
::     !>  ^-  action:linedb
::     :^  %commit  repo-name  branch-name
::     ?~  file-contents  (~(del by snap) file-path)
::     %+  ~(put by snap)  file-path
::     ?.  ((sane %t) u.file-contents)  ~[u.file-contents]
::     (to-wain:format u.file-contents)
::   ~&  %z^%sf^%4
::   ;<  empty-vase=vase  bind:m
::     ?:  =(old-repo-info repo-info)  (pure:m !>(~))
::     ;<  ~  bind:m
::       %+  poke-our  %ziggurat
::       :-  %ziggurat-action
::       !>  ^-  action:zig
::       :^  project-name  desk-name  ~
::       :-  %send-update
::       !<  update:zig
::       %.  repo-info
::       %~  repo-info  make-update-vase:zig-lib
::       [project-name desk-name %modify-file ~]
::     (pure:m !>(~))
::   ~&  %z^%sf^%5
::   (pure:m !>(~))
::
++  modify-files
  |=  $:  files-map=(map path (unit @))  ::  =(~ val) -> delet
          maybe-repo-info=(unit repo-info:zig)
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  =/  files=(list (pair path (unit @)))  ~(tap by files-map)
  ~&  %z^%sf^%0^[(turn files |=([p=path q=(unit @)] [p ?=(^ q)])) maybe-repo-info]
  ;<  state=state-1:zig  bind:m  get-state:zig-threads
  ;<  =bowl:strand  bind:m  get-bowl
  =/  old-project=project:zig
    (~(got by projects.state) project-name)
  =/  =desk:zig  (got-desk:zig-lib old-project desk-name)
  =/  old-repo-info=repo-info:zig  repo-info.desk
  ~&  %z^%sf^%1^old-repo-info
  ;<  repo-info-vase=vase  bind:m
    %+  branch-if-non-head  most-recently-seen-commit.desk
    ?~(maybe-repo-info repo-info.desk u.maybe-repo-info)
  =+  !<(=repo-info:zig repo-info-vase)
  ~&  %z^%sf^%3^repo-info
  =/  new-project=project:zig
    %^  put-desk:zig-lib  old-project  desk-name
    desk(repo-info repo-info)
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    :^  project-name  desk-name  ~
    :-  %set-ziggurat-state
    %=  state
        projects
      (~(put by projects.state) project-name new-project)
    ==
  ;<  empty-vase=vase  bind:m
    =/  cages=(list cage)
      %+  update-linedb-watches-cages:zig-lib
        :-  project-name
        (project-to-repo-infos:zig-lib old-project)
      :-  project-name
      (project-to-repo-infos:zig-lib new-project)
    |-
    ?~  cages  (pure:m !>(~))
    ;<  ~  bind:m  (poke-our %ziggurat i.cages)
    $(cages t.cages)
  ;<  ~  bind:m  (sleep ~s1)  ::  TODO: necessary?
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
  =.  snap
    |-
    ?~  files  snap
    %=  $
        files  t.files
        snap
      ?~  q.i.files  (~(del by snap) p.i.files)
      %+  ~(put by snap)  p.i.files
      ?.  ((sane %t) u.q.i.files)  ~[u.q.i.files]
      (to-wain:format u.q.i.files)
    ==
  ;<  ~  bind:m
    %+  poke-our  %linedb
    :-  %linedb-action
    !>  ^-  action:linedb
    [%commit repo-name branch-name snap]
    :: :^  %commit  repo-name  branch-name
    :: ?~  file-contents  (~(del by snap) file-path)
    :: %+  ~(put by snap)  file-path
    :: ?.  ((sane %t) u.file-contents)  ~[u.file-contents]
    :: (to-wain:format u.file-contents)
  ~&  %z^%sf^%4
  ;<  empty-vase=vase  bind:m
    ?:  =(old-repo-info repo-info)  (pure:m !>(~))
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :^  project-name  desk-name  ~
      :-  %send-update
      !<  update:zig
      %.  repo-info
      %~  repo-info  make-update-vase:zig-lib
      [project-name desk-name %modify-files ~]
    (pure:m !>(~))
  ~&  %z^%sf^%5
  (pure:m !>(~))
::
::  +watch-for-desk-update
::   inspired by kiln-sync, see e.g.,
::   https://github.com/urbit/urbit/blob/d363f01080100f485885c15009b13f3a0590f228/pkg/arvo/lib/hood/kiln.hoon#L1125-L1134
::   https://github.com/urbit/urbit/blob/d363f01080100f485885c15009b13f3a0590f228/pkg/arvo/lib/hood/kiln.hoon#L1176
::   https://github.com/urbit/urbit/blob/d363f01080100f485885c15009b13f3a0590f228/pkg/arvo/lib/hood/kiln.hoon#L1194
::
++  watch-for-desk-update
  |=  [who=@p desk-name=@tas]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  now=@da  bind:m  get-time
  ;<  =riot:clay  bind:m
    (warp who desk-name ~ %sing %w da+now /)
  ?~  riot  (pure:m !>(%.n))
  ?.  ?=(%cass p.r.u.riot)  (pure:m !>(%.n))
  =/  [current-revision-number=@ @]  !<([@ud @] q.r.u.riot)
  =/  next-revision-number=@ud  +(current-revision-number)
  ;<  =riot:clay  bind:m
    %^  warp  who  desk-name
    [~ %sing %w ud+next-revision-number /]
  ?~  riot  (pure:m !>(%.n))
  ;<  =riot:clay  bind:m
    %^  warp  who  desk-name
    [~ %sing %v ud+next-revision-number /]
  ?~  riot  (pure:m !>(%.n))
  (pure:m !>(%.y))
::
++  update-pyro-desks-to-repo
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  %z^%updtr^%0
  =*  repo-name  desk-name
  ;<  state=state-1:zig  bind:m  get-state:zig-threads
  =/  =project:zig  (~(got by projects.state) project-name)
  =/  =desk:zig     (got-desk:zig-lib project repo-name)
  =*  repo-host    repo-host.repo-info.desk
  =*  branch-name  branch-name.repo-info.desk
  =*  commit-hash  commit-hash.repo-info.desk
  ?^  commit-hash
    ::  dependency desk is fixed at given commit
    ::   -> do not update
    (pure:m !>(~))
  ::  dependency desk is set to %head
  ::   -> do update
  ::
  ~&  %z^%updtr^%1
  =*  sync-desk-to-vship  sync-desk-to-vship.project
  =*  whos=(list @p)
    ~(tap in (~(get ju sync-desk-to-vship) repo-name))
  ~&  %z^%updtr^sync-desk-to-vship^repo-name^whos
  ;<  empty-vase=vase  bind:m
    ?~  whos  (pure:m !>(~))
    %-  (start-commit-thread whos)
    [repo-host repo-name branch-name commit-hash]
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    (make-read-repo-cage:zig-lib project-name desk-name ~)
  |^
  ;<  paths-to-build=(list path)  bind:m  get-paths-to-build
  ;<  empty-vase=vase  bind:m
    |-
    ?~  paths-to-build  (pure:m !>(~))
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :^  project-name  desk-name  ~
      [%build-file i.paths-to-build]
    $(paths-to-build t.paths-to-build)
  ;<  =bowl:strand  bind:m  get-bowl
  =*  zl  zig-lib(our.bowl our.bowl, now.bowl now.bowl)
  =/  most-recent-commit-hash=(unit @ux)
    %^  get-most-recent-commit:zl  repo-host  repo-name
    branch-name
  ?~  most-recent-commit-hash
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      :^  project-name  desk-name  ~
      :-  %send-update
      !<  update:zig
      %.  %-  crip  %+  weld  "did not find commits in repo"
          " {<repo-host>} {<repo-name>} {<branch-name>}"
      %~  linedb  make-error-vase:zig-lib
      :_  %error
      [project-name desk-name %update-pyro-desks-to-repo ~]
    (pure:m !>(~))
  ;<  state=state-1:zig  bind:m  get-state:zig-threads
  =/  =project:zig  (~(got by projects.state) project-name)
  =/  =desk:zig  (got-desk:zig-lib project repo-name)
  =.  most-recently-seen-commit.desk
    u.most-recent-commit-hash
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
  (pure:m !>(~))
  ::
  ++  get-paths-to-build
    =/  m  (strand ,(list path))
    ^-  form:m
    ;<  =bowl:strand  bind:m  get-bowl
    =*  scry-prefix=path
      :^  (scot %p our.bowl)  %linedb  (scot %da now.bowl)
      /(scot %p repo-host)/[desk-name]/[branch-name]
    =+  .^  log=(list [hash=@ux @ @ @])
            %gx
            (snoc scry-prefix %noun)
        ==
    ?~  log  !!  :: TODO
    =*  head-hash  (scot %ux hash.i.log)
    ?~  t.log
      ::  only have one commit
      ::   -> skip diffing logic and build all
      (pure:m ~(tap in to-compile.desk))
    ::  have head and previous commit
    ::   -> build only files that were updated
    =*  old-head-hash  (scot %ux hash.i.t.log)
    =+  .^  diff=(map path (urge:clay @t))
            %gx
            %+  weld  scry-prefix
            /diff/[old-head-hash]/[head-hash]/noun
        ==
    =*  updated-files=(set path)
      %-  ~(gas in *(set path))
      %+  murn  ~(tap by diff)
      |=  [p=path u=(urge:clay @t)]
      ?:  =(1 (lent u))  ~  `p
    %-  pure:m
    ~(tap in (~(int in updated-files) to-compile.desk))
  --
::
++  does-desk-exist
  |=  desk-name=@tas
  =/  m  (strand ,?)
  ^-  form:m
  ;<  a=arch  bind:m  (scry arch /cy/[desk-name])
  (pure:m |(?=(^ fil.a) ?=(^ dir.a)))
::
++  build
  |=  [file-path=path repo-infos=(list repo-info:zig)]
  =/  m  (strand ,vase)
  |^  ^-  form:m
  ?>  ?=(^ file-path)
  ;<  state=state-1:zig  bind:m  get-state:zig-threads
  =?  repo-infos  ?=(~ repo-infos)
    =*  project  (~(got by projects.state) project-name)
    ?.  =(project-name desk-name)
      :_  ~
      =*  desk  (got-desk:zig-lib project desk-name)
      repo-info.desk
    %+  turn  (val-desk:zig-lib project)
    |=(=desk:zig repo-info.desk)
  ?.  =(%con i.file-path)
    ;<  =bowl:strand  bind:m  get-bowl
    ;<  ~  bind:m
      %+  poke-our  %linedb
      :-  %linedb-action
      !>  ^-  action:linedb
      [%build repo-infos file-path [%ted tid.bowl]]
    ~&  %zb^%non-con^%0
    ;<  build-result=vase  bind:m  (take-poke %linedb-update)
    ~&  %zb^%non-con^%1
    =+  !<(=update:linedb build-result)
    ?.  ?=(%build -.update)
      %-  return-error
      %+  weld  "{<file-path>} build failed unexpectedly,"
      " please see dojo for compilation errors"
    ?:  ?=(%& -.result.update)
      (return-success p.result.update)
    =*  error
      (reformat-compiler-error:zig-lib p.result.update)
    %-  return-error
    %+  weld  "{<file-path>} build failed: {<error>}"
    " please see dojo for additional compilation errors"
  ?>  ?=(^ repo-infos)
  =*  repo-host    repo-host.i.repo-infos
  =*  branch-name  branch-name.i.repo-infos
  =*  commit-hash  commit-hash.i.repo-infos
  =*  commit=@ta
    ?~  commit-hash  %head  (scot %ux u.commit-hash)
  =*  path-prefix=path
   /(scot %p repo-host)/[desk-name]/[branch-name]/[commit]
  ;<  jam-mar=(unit @t)  bind:m
    %+  scry  (unit @t)
    (welp [%gx %linedb path-prefix] /mar/jam/hoon/noun)
  ?~  jam-mar
    %-  return-error
    %+  weld  "/mar/jam/hoon does not exist in %linedb"
    " {<`path`path-prefix>}; please add and try again"
  ;<  smart-lib-vase=vase  bind:m
    (scry vase /gx/ziggurat/get-smart-lib-vase/noun)
  ;<  =bowl:strand  bind:m  get-bowl
  =*  zl  zig-lib(now.bowl now.bowl, our.bowl our.bowl)
  =/  =build-result:zig
    %^  build-contract:zl  smart-lib-vase  path-prefix
    file-path
  ?:  ?=(%| -.build-result)
    %-  return-error
    %+  weld
      "contract compilation failed at {<`path`file-path>}"
    " with error:\0a{<(trip p.build-result)>}"
  =*  jam-path
    (need (convert-contract-hoon-to-jam:zig-lib file-path))
  ;<  empty-vase=vase  bind:m
    %-  modify-files  :_  ~
    %+  ~(put by *(map path (unit @t)))  jam-path
    `(jam p.build-result)
  ;<  ~  bind:m
    %^  watch-our  /save-done  %linedb
    [%branch-updates (snip path-prefix)]
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    %^  make-read-repo-cage:zig-lib  project-name  desk-name
    ~
    :: request-id
  ;<  save-done=cage  bind:m  (take-fact /save-done)
  ;<  ~  bind:m  (leave-our /save-done %linedb)
  ?.  ?=(%linedb-update p.save-done)     !!
  =+  !<(=update:linedb q.save-done)
  ?.  ?=(%new-data -.update)             !!
  ?.  =((snip path-prefix) path.update)  !!
  (return-success !>(p.build-result))
  ::
  ++  return-success
    |=  result=vase
    (pure:m !>(`(each vase tang)`[%& result]))
  ::
  ++  return-error
    |=  message=tape
    (pure:m !>(`(each vase tang)`[%| [%leaf message]~]))
  --
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
  |=  [focused-project=@t request-id=(unit @t)]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  ~  bind:m
    %+  poke-our  %ziggurat
    :-  %ziggurat-action
    !>  ^-  action:zig
    [focused-project %$ request-id %take-snapshot ~]
  ;<  ~  bind:m  (sleep ~s1)
  (pure:m !>(~))
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
  ?~  whos  (pure:m !>(~))
  ::  TODO: per pyro ship?
  ~&  %z^%cfldb^%0
  ;<  =update:pyro  bind:m
    (scry update:pyro /gx/pyro/ships/noun)
  ?.  ?&  ?=(%ships -.update)
          %.  i.whos
          ~(has in (~(gas in *(set @p)) ships.update))
      ==
    ~&  [%z %cfldb %bail %0 ?=(%ships -.update)]
    (pure:m !>(~))
  =*  who  (scot %p i.whos)
  ;<  desk-names=(set @tas)  bind:m
    %+  scry  (set @tas)
    /gx/pyro/i/[who]/cd/[who]//0/noun
  ~&  %z^%cfldb^%1
  ;<  =bowl:strand  bind:m  get-bowl
  =*  our  (scot %p our.bowl)
  =*  now  (scot %da now.bowl)
  =/  =yaki:clay
    ?.  (~(has in desk-names) repo-name)  *yaki:clay
    ~&  %z^%cfldb^%10
    =+  .^  =domo:clay
            %gx
            :^  our  %pyro  now
            /i/[who]/cv/[who]/[repo-name]/0/dome
        ==
    ~&  %z^%cfldb^%11
    ?:  =(~ hit.domo)  *yaki:clay
    ~&  %z^%cfldb^%12
    =*  head  (scot %uv (~(got by hit.domo) let.domo))
    .^  yaki:clay
        %gx
        :^  our  %pyro  now
        /i/[who]/cs/[who]/[repo-name]/0/yaki/[head]/yaki
    ==
  ;<  =rang:clay  bind:m
    (scry rang:clay /gx/pyro/i/[who]/cx/[who]//0/rang/rang)
  ~&  %z^%cfldb^%2
  ;<  ~  bind:m
    %+  poke-our  %linedb
    :-  %linedb-action
    !>  ^-  action:linedb
    :^  %make-install-args  repo-host  repo-name
    [branch-name commit-hash [%ted tid.bowl] `[yaki rang]]
  ~&  %z^%cfldb^%3
  ;<  install-args-result=vase  bind:m
    (take-poke %linedb-update)
  ~&  %z^%cfldb^%4
  =+  !<(=update:linedb install-args-result)
  ?.  ?=(%make-install-args -.update)  !!  ::  TODO
  ?:  ?=(%| -.result.update)           !!  ::  TODO
  =*  park-args  p.result.update
  ~&  %z^%cfldb^%5
  ;<  ~  bind:m
    %-  send-events:pyro-lib
    %+  ue-to-pes:pyro-lib  whos
    [/c/commit %park park-args]
  (pure:m !>(~))
::
++  commit-install-start
  |=  $:  whos=(list @p)
          =repo-dependencies:zig
          install=(map @tas (list @p))
          start-apps=(map @tas (list @tas))
          =long-operation-info:zig
          is-top-level=?
      ==
  =/  commit-poll-duration=@dr  ~s1
  =/  start-poll-duration=@dr   (div ~s1 10)
  |^
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  empty-vase=vase  bind:m
    (send-long-operation-update long-operation-info)
  ~&  %cis^%0
  ;<  =bowl:strand  bind:m  get-bowl
  ;<  empty-vase=vase  bind:m
    %+  iterate-over-repo-dependencies  repo-dependencies
    (start-commit-thread whos)
  ~&  %cis^%1^repo-dependencies
  =*  desk-names=(list @tas)
    %+  turn  repo-dependencies
    |=([@ desk-name=@tas *] desk-name)
  ;<  ~  bind:m
    (iterate-over-whos whos (block-on-commit desk-names))
  ;<  empty-vase=vase  bind:m
    %-  send-long-operation-update
    ?~  long-operation-info  ~
    :^  ~  name.u.long-operation-info
      steps.u.long-operation-info
    `%install-and-start-apps-on-pyro-ships
  ;<  ~  bind:m  (sleep ~s1)
  ?:  ?|  =(0 ~(wyt by install))
          (~(all by install) |=(a=(list @) ?=(~ a)))
      ==
    ?.  is-top-level  (pure:m !>(~))
    %-  send-long-operation-update
    ?~  long-operation-info  ~
    :^  ~  name.u.long-operation-info
    steps.u.long-operation-info  ~
  ~&  %cis^%2
  ;<  ~  bind:m  install-and-start-apps
  ~&  %cis^%3
  ?.  is-top-level  (pure:m !>(~))
  %-  send-long-operation-update
  ?~  long-operation-info  ~
  :^  ~  name.u.long-operation-info
  steps.u.long-operation-info  ~
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
    (scry ? /gx/pyro/i/[w]/gu/[w]/[app]/0/$/noun)
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
      %+  %~  send-pyro-dojo  zig-threads
          [project-name desk-name ~]
      who  (crip "|install our {<desk-name>}")
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
      %+  %~  send-pyro-dojo  zig-threads
          [project-name desk-name ~]
        who
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
          =long-operation-info:zig
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  %sp^%0^repo-dependencies
  =.  repo-dependencies
    :_  repo-dependencies
    [repo-host project-name %master ~]  ::  TODO: generalize from [%master ~]
  ;<  empty-vase=vase  bind:m
    (send-long-operation-update long-operation-info)
  ~&  %sp^%10^repo-dependencies
  ;<  state=state-1:zig  bind:m  get-state:zig-threads
  ~&  %sp^%11
  =/  old-focused-project=@tas  focused-project.state
  |^
  ?:  =('global' project-name)
    ;<  ~  bind:m
      %-  send-error
      (crip "{<`@tas`project-name>} face reserved")
    return-failure
  ;<  ~  bind:m  get-dependency-repos
  ~&  %sp^%1
  ;<  new-state=state-1:zig  bind:m  set-initial-state
  =.  state  new-state
  ~&  %sp^%2
  ;<  =bowl:strand  bind:m  get-bowl
  ;<  empty-vase=vase  bind:m
    (iterate-over-desks repo-dependencies make-read-repo)
  ;<  empty-vase=vase  bind:m
    %-  send-long-operation-update
    ?~  long-operation-info  ~
    long-operation-info(current-step.u `%start-new-ships)
  ;<  ~  bind:m  start-new-ships
  ~&  %sp^%3
  ;<  ~  bind:m  send-new-project-update
  ~&  %sp^%4
  ;<  ~  bind:m  send-state-views
  =.  repo-dependencies
    %+  turn  repo-dependencies
    |=  [@ rn=@tas bn=@tas ch=(unit @ux)]
    [our.bowl rn bn ch]
  ~&  %sp^%5^repo-dependencies
  ;<  empty-vase=vase  bind:m
    %^  commit-install-start  whos  repo-dependencies
    :^  install  start-apps
      ?~  long-operation-info  ~
      %=  long-operation-info
          current-step.u  `%commit-files-to-pyro-ships
      ==
    %.n
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
    ;<  empty-vase=vase  bind:m
      (fetch-repo repo-host repo-name branch-name ~ ~)
    $(repo-dependencies t.repo-dependencies)
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
    ?~  repo-dependencies  ~
    =*  repo-dependency-names=(list @tas)
      %+  turn  t.repo-dependencies
      |=([@ desk-name=@tas *] desk-name)
    ~&  %z^%msdtv^repo-dependencies^repo-dependency-names
    %-  ~(gas by *sync-desk-to-vship:zig)
    %+  turn  repo-dependency-names
    |=  desk-name=@tas
    [desk-name (~(gas in *(set @p)) whos)]
  ::
  ++  set-initial-state
    =/  m  (strand ,state-1:zig)
    ^-  form:m
    ;<  =bowl:strand  bind:m  get-bowl
    =/  =project:zig
      (~(gut by projects.state) project-name *project:zig)
    =.  desks.project
      %+  turn  repo-dependencies
      |=  =repo-info:zig
      =|  =desk:zig
      :-  repo-name.repo-info
      %=  desk
          name       repo-name.repo-info
          repo-info  repo-info(repo-host our.bowl)  ::  will %branch foreign-hosted repos
      ==
    =.  start-apps.project  start-apps
    =.  state
      %=  state
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
    ;<  ~  bind:m
      %+  poke-our  %ziggurat
      :-  %ziggurat-action
      !>  ^-  action:zig
      [project-name project-name request-id %change-focus ~]
    ;<  ~  bind:m  (sleep ~s1)
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
  ::
  ++  return-failure
    =/  m  (strand ,vase)
    ^-  form:m
    ;<  state=state-1:zig  bind:m  get-state:zig-threads
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
    ;<  ~  bind:m
      %.  `project-name
      %~  block-on-previous-operation  zig-threads
      [project-name desk-name ~]
    (pure:m !>(`?`%.y))
  --
--
