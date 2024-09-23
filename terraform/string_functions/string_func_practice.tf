/*Upper function*/ /*It changes string to CAPITAL LETTERS*/

variable "names" {
  type    = list(string)
  default = ["mithun", "murugan", "palani"]
}

output "upper_name" {
  value = [for x in var.names : upper(x)]
}

/*chomp Function*/ /*It removes newline characters at the end of a string*/
variable "names1" {
  type    = list(string)
  default = ["mithu\n"]
}

output "chomp_name" {
  value = [for x in var.names1 : chomp(x)]
}


/*endswith Function*/
/*Accpts 2 arguments and returns true if the first string ends with exact second string */
variable "names2" {
  type    = list(string)
  default = ["mithun", "mithun"]
}

output "endswith_name" {
  value = endswith(var.names2[0], var.names2[1])
}


/*format Function*/ /*Accpts 2 arguments and Convert to integer number */

variable "names3" {
  type    = list(any)
  default = ["mithun is having %d digit salary", 10]
}

output "format_name" {
  value = format(var.names3[0], var.names3[1])
}


/*formatlist Function*/ /*need to check*/

# variable "names4" {
#   type    = list(any)
#   default = ""
# }

# output "format_name" {
#   value = format(var.names3[0], var.names3[1])
# }


/*join  Function*/ /*need to check*/

# variable "names5" {
#   type    = list(any)
#   default = ["-", ["mithun", "modali"]]
# }

# output "join_name" {
#   value = join(var.names5[0], var.names5[1])
# }


/*regex  Function*/ /*Accpts 2 arguments and display Beginning numbers/characters in a string */

variable "names6" {
  type    = string
  default = "mithun123"
}

output "regex_name" {
  value = regex("[0-9]+", var.names6)
}


/*regexall  Function*/ /*Accpts 2 arguments and display ALL numbers/characters in a string */

variable "names7" {
  type    = string
  default = "456mithun123"
}

output "regexall_name" {
  value = regexall("[0-9]+", var.names7)
}


/*replace  Function*/
/*Accpts 3 arguments and replace first character with second character given in a string */

variable "names8" {
  type    = string
  default = "5+5"
}

output "replace_name" {
  value = replace(var.names8, "+", "-")
}



/*split  Function*/
/*Accpts 2 arguments and remove the character entered in a string */
variable "names9" {
  type    = string
  default = "5+5, 8+8, 6+6"
}

output "split_name" {
  value = split("+", var.names9)
}


/*startswith  Function*/
/*Accpts 2 arguments and returns true if the first string strats with exact second string */

variable "names10" {
  type    = list(string)
  default = ["mithun", "mithun"]
}

output "startswith_name" {
  value = startswith(var.names10[0], var.names10[1])
}


/*strcontains  Function*/
/*Accpts 2 arguments and display Boolean value if string contains given character*/

variable "names11" {
  type    = list(string)
  default = ["mithun"]
}

output "strcontains_name" {
  value = strcontains(var.names11[0], "onr")
}


/*strrev Function*/ /*It reverse the string*/

variable "names12" {
  type    = string
  default = "mithun"
}

output "strrev_name" {
  value = strrev(var.names12)
}


/*substr Function*/ /*Accpts 3 arguments and gives MIDDLE of the string*/

variable "names13" {
  type    = string
  default = "mithun"
}

output "substr_name" {
  value = substr(var.names13, 1, 3)
}



/*title Function*/ /*It changes FIRST LETTER to CAPITAL LETTER*/

variable "names14" {
  type    = string
  default = "mithun"
}

output "title_name" {
  value = title(var.names14)
}


/*trim Function*/ /*Accpts 2 arguments and TRIMS the letters which are mentioned*/

variable "names15" {
  type    = string
  default = "malayalam"
}

output "trim_name" {
  value = trim(var.names15, "mal")
}



/*trimprefix Function*/ /*Accpts 2 arguments and TRIMS the First consecutive letters which are mentioned*/

variable "names16" {
  type    = string
  default = "malayalam"
}

output "trimprefix_name" {
  value = trimprefix(var.names16, "mal")
}


/*trimsuffix Function*/ /*Accpts 2 arguments and TRIMS the Last consecutive letters which are mentioned*/

variable "names17" {
  type    = string
  default = "malayalam"
}

output "trimsuffix_name" {
  value = trimsuffix(var.names17, "yalam")
}


/*trimspace Function*/ /*need to check*/

variable "names18" {
  type    = string
  default = "m       alayalam\n\n"
}

output "trimspace_name" {
  value = trimspace(var.names18)
}


/*Lower function*/ /*It changes string to Lower case*/

variable "names19" {
  type    = list(string)
  default = ["MITHUN", "MURUGAN", "PALANI"]
}

output "lower_name" {
  value = [for x in var.names19 : lower(x)]
}



