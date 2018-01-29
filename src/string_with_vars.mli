(** String with variables of the form ${...} or $(...)

    Variables cannot contain "${", "$(", ")" or "}". For instance in "$(cat ${x})", only
    "${x}" will be considered a variable, the rest is text. *)

open Import

type t
(** A sequence of text and variables. *)

val t : t Sexp.Of_sexp.t
(** [t ast] takes an [ast] sexp and returns a string-with-vars.  This
   function distinguishes between unquoted variables — such as ${@} —
   and quoted variables — such as "${@}". *)

val loc : t -> Loc.t
(** [loc t] returns the location of [t] — typically, in the jbuild file. *)

val sexp_of_t : t -> Sexp.t

val to_string : t -> string

(** [t] generated by the OCaml code. The first argument should be
   [__POS__]. The second is either a string to parse, a variable name
   or plain text. *)
val virt             : (string * int * int * int) -> string -> t
val virt_var         : (string * int * int * int) -> string -> t
val virt_quoted_var  : (string * int * int * int) -> string -> t
val virt_text        : (string * int * int * int) -> string -> t

val unquoted_var : t -> string option
(** [unquoted_var t] return the [Some name] where [name] is the name of
   the variable if [t] is solely made of a variable and [None] otherwise. *)

val vars : t -> String_set.t
(** [vars t] returns the set of all variables in [t]. *)

val fold : t -> init:'a -> f:('a -> Loc.t -> string -> 'a) -> 'a
(** [fold t ~init ~f] fold [f] on all variables of [t], the text
   portions being ignored. *)

val iter : t -> f:(Loc.t -> string -> unit) -> unit
(** [iter t ~f] iterates [f] over all variables of [t], the text
   portions being ignored. *)

val expand : t -> f:(Loc.t -> string -> string option) -> string
(** [expand t ~f] return [t] where all variables have been expanded
   using [f].  If [f] returns [Some x], the variable is replaced by
   [x]; if [f] returns [None], the variable is inserted as [${v}] or
   [$(v)] — depending on the original concrete syntax used — where [v]
   is the name if the variable. *)

val partial_expand : t -> f:(Loc.t -> string -> string option)
                     -> (string, t) either
(** [partial_expand t ~f] is like [expand] where all variables that
   could be expanded (i.e., those for which [f] returns [Some _]) are.
   If all the variables of [t] were expanded, a string is returned.
   If [f] returns [None] on at least a variable of [t], it returns a
   string-with-vars. *)

