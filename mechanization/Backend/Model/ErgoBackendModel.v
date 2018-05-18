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

Require Import Qcert.Common.CommonSystem.

Require Import ErgoSpec.Backend.Model.ErgoEnhancedModel.
Require Import ErgoSpec.Backend.ForeignErgo.

Module Type ErgoBackendModel.
  Definition ergo_foreign_data : foreign_data := enhanced_foreign_data.
  Axiom ergo_data_to_json_string : String.string -> data -> String.string.
  Axiom ergo_backend_closure : Set.
  Axiom ergo_backend_lookup_table : Set.
  Axiom ergo_backend_foreign_ergo : foreign_ergo.
  Axiom ergo_backend_stdlib : backend_lookup_table.
End ErgoBackendModel.

