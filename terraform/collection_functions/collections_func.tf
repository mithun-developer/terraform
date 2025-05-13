/*alltrue  function*/ /*need to check*/

variable "collect1" {
  type    = list(number)
  default = [90, 80, 75]
}

output "coll_alltrue" {
  value = alltrue([for x in var.collect1 : x >= 90])
  //value = [for x in var.coll_alltrue : alltrue(x > 90)]

}



/*anytrue  function*/

variable "collect2" {
  type    = list(number)
  default = [90, 80, 75]
}

output "coll_anytrue" {
  value = anytrue([for x in var.collect2 : x > 90])


}


/*chunklist   function*/

variable "collect3" {
  type    = list(string)
  default = ["mithun", "murugan", "palani"]
}

output "coll_chunklist" {
  value = chunklist(var.collect3, 1)


}


/*coalesce function*/

variable "coalesce1" {
  type    = string
  default = ""
}
variable "coalesce2" {
  type    = string
  default = "murugan"
}
variable "coalesce3" {
  type    = string
  default = "palani"
}

output "coll_coalesce" {
  value = coalesce(var.coalesce1, var.coalesce2, var.coalesce3)


}


/*coalescelist function*/

variable "collect5" {
  type    = list(string)
  default = ["", "palani", "murugan"]
}

output "coll_coalescelist" {
  value = coalescelist(var.collect5)


}

/*compact  function*/
/*takes a list of strings and returns a new list with any null or empty string elements removed.*/

variable "collect6" {
  type    = list(string)
  default = ["", "palani", "murugan"]
}

output "coll_compact" {
  value = compact(var.collect6)


}


/*concat function*/
/* takes two or more lists and combines them into a single list*/

output "coll_concat" {
  value = concat(["", "palani", "murugan"], ["swamy", "kumara"])
}
