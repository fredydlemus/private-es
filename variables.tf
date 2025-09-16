variable "s3_mirror_bucket" {
  description = "The name of the s3 mirror bucket"
  type        = string
  default     = "eks-artifact-bucket"
}

variable "s3_mirror_prefix" {
  description = "The prefix for the s3 mirror bucket"
  type        = string
  default     = "tools"
}