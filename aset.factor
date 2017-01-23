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
! date  : 2017-01-22

USING: io locals http http.client arrays sequences kernel
accessors json.reader assocs strings command-line namespaces
io.encodings.utf8 io.files io.launcher io.pathnames ;
IN: aset

<PRIVATE

CONSTANT: path "/user/repos"

TUPLE: repository
    { name string read-only }
    { url string read-only } ;

TUPLE: config
    { base-url string read-only }
    { user string read-only }
    { token string read-only } ;

C: <repository> repository

C: <config> config

: basic-auth-header ( config -- basic )
    [ user>> ] [ token>> ] bi basic-auth ;

: generate-header ( config -- header )
    dup base-url>> path append
    <get-request>
    swap basic-auth-header
    "Authorization" set-header ;

: request ( config -- response )
    generate-header http-request drop ;

: get-value ( key json -- val )
    at* drop ;

: read-repositories ( json -- repositories )
    [
        "fork" swap get-value not
    ] filter
    [
        [ "name" swap get-value ]
        [ "ssh_url" swap get-value ] bi
        <repository>
    ] map ;

: pull-repository-command ( dir -- command )
    "-C" swap "git" -rot 3array
    { "pull" "origin" "master" }
    append " " join ;

: clone-repository-command ( url dir -- command )
    2array { "git" "clone" }
    swap append " " join ;

: read-config ( path -- config )
    utf8 file-lines concat json>
    [ "base-url" swap get-value ]
    [ "user" swap get-value ]
    [ "token" swap get-value ] tri
    <config> ;

:: fetch ( dir repositories -- )
    repositories [
        [ name>> dir swap append-path ]
        [ url>> ] bi
        swap dup
        pull-repository-command
        run-process wait-for-process 0 = [
            ! success
            2drop
        ] [
            dup clone-repository-command
            run-process wait-for-process 0 = [
                ! success
                drop
            ] [
                "failure: " swap
                2array concat print
            ] if
        ] if
    ] each ;

PRIVATE>

: run ( -- )
    command-line get [
        nl
    ] [
        dup first swap second
        read-config request body>> json>
        read-repositories
        fetch
    ] if-empty ;

! aset [directory path] [config file path]
MAIN: run
