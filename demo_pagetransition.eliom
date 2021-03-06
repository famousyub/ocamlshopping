[%%shared
(* This demo illustrates Eliom's DOM caching feature.

   By running [Eliom_client.onload Eliom_client.push_history_dom] one
   can push the DOM of the current page into Eliom's cache. Every page
   which is cached in this manner will be immediately served from the
   cache instead of being charged from the server or regenerated by
   the client. Also the scroll position is restored that the page had
   at the end of the last visit. *)
open Eliom_content]

[%%shared open Html]
[%%shared open Html.D]
[%%client open Js_of_ocaml_lwt]

(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-page-transition"; ""])
    ~meth:(Eliom_service.Get Eliom_parameter.unit) ()

let%server detail_page_service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-page-transition"; "detail"; ""])
    ~meth:(Eliom_service.Get (Eliom_parameter.int "page"))
    ()

(* Make service available on the client *)
let%client service = ~%service
let%client detail_page_service = ~%detail_page_service
(* Name for demo menu *)
let%shared name () = [%i18n Demo.S.pagetransition]
(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-transition"

let%shared create_item index =
  let open F in
  li
    ~a:
      [ a_class
          ["demo-list-item"; Printf.sprintf "demo-list-item-%d" (index mod 5)]
      ]
    [a ~service:detail_page_service [txt (Printf.sprintf "list%d" index)] index]

let%shared page () =
  let l =
    (fun i -> create_item (i + 1))
    |> Array.init 10 |> Array.to_list
    |> ul ~a:[a_class ["demo-list"]]
  in
  let add_button =
    div ~a:[a_class ["demo-button"]] [%i18n Demo.pagetransition_add_button]
  in
  ignore
    [%client
      ((* It is the address of the dom that will be stored in cache, so
           it doesn't matter when [push_history_dom] is called. However,
           it is important that the dom is bound to the right state id.
           So it is better to call [push_history_dom] in Eliom_client.onload,
           when the state id has already been updated and the dom of
           the current page is ready. *)
       Eliom_client.onload Eliom_client.push_history_dom;
       let counter =
         let r = ref 10 in
         fun () ->
           r := !r + 1;
           !r
       in
       Lwt_js_events.clicks (To_dom.of_element ~%add_button) (fun _ _ ->
           Html.Manip.appendChild ~%l (create_item (counter ()));
           Lwt.return_unit)
        : unit Lwt.t)];
  Lwt.return
    [ h1 [%i18n Demo.pagetransition_list_page]
    ; p [%i18n Demo.pagetransition_intro]
    ; l
    ; add_button ]

let%shared make_detail_page page () =
  let back_button =
    div ~a:[a_class ["demo-button"]] [%i18n Demo.pagetransition_back_button]
  in
  ignore
    [%client
      (Lwt.async (fun () ->
           Lwt_js_events.clicks (To_dom.of_element ~%back_button) (fun _ _ ->
               Js_of_ocaml.Dom_html.window##.history##back;
               Lwt.return_unit))
        : unit)];
  [ h1
      ([%i18n Demo.pagetransition_detail_page]
      @ [txt (Printf.sprintf " %d" page)])
  ; back_button ]
