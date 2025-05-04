resource "aws_dynamodb_table" "lookup" {
  name           = "${var.environment}-lookup"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}