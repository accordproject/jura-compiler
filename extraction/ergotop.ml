(*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

open ErgoComp
open ParseUtil

let welcome () =
  if Unix.isatty Unix.stdin
  then print_string ("Welcome to ERGOTOP version " ^ (Util.string_of_char_list ergo_version) ^ "\n")
  else ()

let prompt () =
  if Unix.isatty Unix.stdin then
    print_string "ergotop$ "
  else ()

let rec read_nonempty_line () =
  prompt () ;
  let line = read_line () in
  if line = "" then
    read_nonempty_line ()
  else
    line ^ "\n"

let rec repl (sctx, dctx) =
  try
    let decl = (ParseUtil.parse_ergo_declaration_from_string "stdin" (read_nonempty_line ())) in
    let result = ergo_eval_decl_via_calculus sctx dctx decl in
    let out = ergo_string_of_result dctx result in
    print_string (Util.string_of_char_list out);
    repl (ergo_maybe_update_context (sctx, dctx) result)
  with
  | ErgoUtil.Ergo_Error e ->
      print_string (ErgoUtil.string_of_error e);
      print_string "\n" ;
      repl (sctx, dctx)
  | End_of_file -> None

let args_list gconf =
  Arg.align
    [
      ("-version", Arg.Unit ErgoUtil.get_version,
       " Prints the compiler version");
      ("--version", Arg.Unit ErgoUtil.get_version,
       " Prints the compiler version");
    ]

let usage =
  "Ergo REPL\n"^
  "Usage: "^Sys.argv.(0)^" [options] cto1 cto2 ... contract1 contract2 ..."

let main args =
  let gconf = ErgoConfig.default_config () in
  let (cto_files,input_files) = ErgoUtil.parse_args args_list usage args gconf in
  List.iter (ErgoConfig.add_cto_file gconf) cto_files;
  let ctos = ErgoConfig.get_ctos gconf in
  let modules = ErgoConfig.get_modules gconf in
  let ctxt = ergo_make_stdlib_ctxt ctos modules in
  welcome ();
  repl (ctxt, ErgoCompiler.ergo_empty_eval_context)

let _ =
  main (ErgoUtil.patch_argv Sys.argv)

