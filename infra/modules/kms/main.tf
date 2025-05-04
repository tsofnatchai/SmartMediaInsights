resource "aws_kms_key" "cmk" {
  description             = "CMK for SmartMediaInsights"
  deletion_window_in_days = 7
}