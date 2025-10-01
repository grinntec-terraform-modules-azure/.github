variable "name" {
  description = "The name of the resource"
  type        = string
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 50
    error_message = "Name must be between 1 and 50 characters."
  }
}

variable "location" {
  description = "The Azure region where the resource should be created"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}