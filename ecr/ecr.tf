resource "aws_ecr_repository" "ecr_service_a" {
    name = "${var.prefix}-ecr-service-a"
    image_tag_mutability = "MUTABLE"
    force_delete = true
    
    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
      "Name" = "${var.prefix}-ecr-service-a"
    }
}

resource "aws_ecr_repository" "ecr_service_b" {
    name = "${var.prefix}-ecr-service-b"
    image_tag_mutability = "MUTABLE"
    force_delete = true

    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
      "Name" = "${var.prefix}-ecr-service-b"
    }
}

resource "aws_ecr_repository" "ecr_service_c" {
    name = "${var.prefix}-ecr-service-c"
    image_tag_mutability = "MUTABLE"
    force_delete = true

    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
      "Name" = "${var.prefix}-ecr-service-c"
    }
}