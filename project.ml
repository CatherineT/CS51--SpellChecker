open Core.Std

exception ImplementMe

type order = Eq | Lt | Gt
type path = Left | Right 

(* signature for BKtree *)
module type BKTREE =
sig

  exception EmptyTree
  exception NodeNotFound

  (* type of distance *)
  type d

  (* type of tree *)
  type tree

  (* Returns an empty BKtree *)
  val empty : tree

  (* Take filename of a dictionary and return BKtree of the dictionary *)
  val load_dict : string -> tree

  (* Insert string into a BKtree *)
  val insert : string -> tree -> tree

  (* Search a BKtree for the given word. Return a list of tuples of the closest 
     word and the distance between them. *)
  val search : string -> tree -> (string * d) list

  (* returns true if word is the BKtree, false otherwise *)
  val is_member : string -> tree -> bool

  (* Same as search, but take in string list to search multiple strings at the
     same time. *)
  val multiple_search : string list -> tree -> (string * d) list list 

  (* Print out results of multiple_search in a readable format *)
  val print_result : string list -> tree -> unit 

  (* Delete the given word from a BKtree. May raise NodeNotFound exception. *)
  val delete : string -> tree -> tree

  val run_tests : unit

end


(* signature for edit distance *)
module type DISTANCE = 
sig

  (* Type of distance *)
  type d

  (* Return distance between words *)
  val distance : string -> string -> d

  (* Zero distance *)
  val zero : d

  (* Return true if two strings are the same, false otherwise*)
  val is_same : string -> string -> bool

  (* Compare two distances *)
  val compare : d -> d -> order

  (* Return Left if d1 is closer to d2 than d3. Otherwise, retrurn Right *)
  val closer_path : d -> d -> d -> path

end

(* signature for BKtree *)
module BKtree(D:DISTANCE) : BKTREE with type d=D.d =
struct

  exception EmptyTree
  exception NodeNotFound

  type d = D.d
  type tree = Leaf | Branch of tree * d * string * tree

  (* Returns an empty BKtree *)
  let empty = Leaf

  let load_dict filename = raise ImplementMe
  (*
    let str_list = In_channel.read_lines filename in 
    let rec load_str_list (lst: sting list) (t:tree) : tree =
      match lst with
      | [] -> t
      | hd::tl -> 
          let s = String.filter ~f:(fun c -> (c >= 'a' && c <= 'z')) hd in
  *)

  let search word t = raise ImplementMe

  let rec is_member word t = 
    match t with
    | Leaf -> false
    | Branch(l, d, s, r) -> 
        if D.is_same word s then true
        else (is_member word l) || (is_member word r)

  let multiple_search wlst t = raise ImplementMe

  let print_result lst = raise ImplementMe

  let rec insert word t = 
    if is_member word t then t else 
    match t with
    | Leaf -> Branch(empty, D.zero, word, empty)
    | Branch(l, d, s, r) -> 
        let d' = D.distance word s in
        match (l, r) with
        | (Leaf, _) -> Branch(Branch(empty, d', word, empty), d, s, r)
        | (_, Leaf) -> Branch(l, d, s, Branch(empty, d', word, empty))
        | (Branch(_, dl, _, _), Branch(_, dr, _, _)) -> 
            match (D.closer_path d' dl dr) with
            | Left -> Branch(insert word l, d, s, r)
            | Right -> Branch(l, d, s, insert word r)
            

  let delete word t = raise ImplementMe

  let run_tests = 
      ()


end

(* implementation for Levenshtein Disance with brute force approach *)
module NaiveLevDistance : DISTANCE with type d=int = 
struct
  
  type d = int

  let distance s1 s2 =
    let (s1, s2) = (String.lowercase s1, String.lowercase s2) in
    let (len1, len2) = (String.length s1, String.length s2) in 
    let rec get_distance (p1:int) (p2:int) : int =
      if p1 = len1 then len2 - p2 else if p2 = len2  then len1 - p1
      else 
        let (c1, c2) = (String.get s1 p1, String.get s2 p2) in
        if c1 = c2 then get_distance (p1 + 1) (p2 + 1)
        else 1 + min (get_distance (p1 + 1) (p2 + 1)) (min 
                  (get_distance (p1 + 1) p2) (get_distance p1 (p2 + 1))) in
    if len1 = 0 then len2 
    else if len2 = 0 then len1
    else get_distance 0 0

  let zero = distance "" ""

  let compare d1 d2 = 
    if d1 = d2 then Eq
    else if d1 < d2 then Lt
    else Gt 

  let is_same s1 s2 =
    match (compare (distance s1 s2) zero) with
    | Eq -> true
    | _ -> false 

  let closer_path d1 d2 d3 =
    if abs(d1 - d2) < abs(d1 - d3) then Left
    else Right 


end


let test_lev_distance f =
  assert((f "evidence" "providence") = 3);
  assert((f "evidence" "provident") = 5);
  assert((f "cook" "snook") = 2);
  assert((f "" "") = 0);
  assert((f "CS51" "CS51") = 0);
  assert((f "cool" "Cool") = 0);
  ()

let _ = test_lev_distance NaiveLevDistance.distance

(* implementation for Levenshtein Distance using dynamic programming concept 
module DynamicLevDistance : DISTANCE with type num=int =
struct
  type num = int
  let distance s1 s2 = pseudo code below
  let compare d1 d2 = raise ImplementMe
end
*)

(* implementation for Damerau–Levenshtein distance using dynamic programming 
module DamerauLevDistance : DISTANCE with type num=int =
struct
  type num = int
  let distance s1 s2 = raise ImplementMe
  let compare d1 d2 = raise ImplementMe
end
*)




