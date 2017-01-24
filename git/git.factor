! Copyright 2017 Yoshihiro Tanaka
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
! 
!   http://www.apache.org/licenses/LICENSE-2.0
! 
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
! 
! Author: Yoshihiro Tanaka <contact@cordea.jp>
! date  : 2017-01-24

USING: io kernel locals sequences arrays strings
literals accessors ;
IN: aset.git

<PRIVATE

CONSTANT: remote "upstream"

: git-command ( path -- command )
    1array { "git" "-C" } swap append ;

PRIVATE>

TUPLE: git
    { path string read-only } ;

C: <git> git

:: push-command ( git branch -- command )
    git path>> git-command
    { "push" $ remote branch }
    append ;

:: add-remote-command ( git url -- command )
    git path>> git-command
    { "remote" "add" $ remote url }
    append ;

:: pull-command ( git branch -- command )
    git path>> git-command
    { "pull" "origin" branch }
    append ;

: clone-command ( git url -- command )
    swap path>> 2array { "git" "clone" }
    swap append ;
