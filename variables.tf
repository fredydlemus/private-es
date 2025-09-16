variable "artifact_bucket" {
  description = "The name of the artifact bucket"
  type        = string
  default     = "eks-artifact-bucket"
}

variable "artifact_prefix" {
  description = "The prefix for the artifact bucket"
  type        = string
  default     = "tools"
}