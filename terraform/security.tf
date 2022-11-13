resource "aws_security_group" "clash-bot-lambda-sg" {
  name   = "clash-bot-time-lambda-sg"
  vpc_id = data.tfe_outputs.clash-bot-discord-bot.values.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}