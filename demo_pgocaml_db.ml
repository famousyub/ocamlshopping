(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

open Os_db

(* We are using PGOCaml to make type safe DB requests to Postgresql.
   The Makefile automatically compiles
   all files *_db.ml with PGOCaml's ppx syntax extension.
*)

let get () =
  full_transaction_block (fun dbh ->
      [%pgsql dbh "SELECT lastname FROM ocsigen_start.users"])
