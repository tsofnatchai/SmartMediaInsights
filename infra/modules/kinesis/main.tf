resource "aws_kinesis_stream" "events" {
  name        = "${var.environment}-events"
  shard_count = 1
  retention_period = 24
}