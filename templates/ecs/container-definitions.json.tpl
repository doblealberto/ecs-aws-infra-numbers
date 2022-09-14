[
    {
        "name": "api",
        "image": "${app_image}",
        "essential": true,
        "memoryReservation": 128,
        "environment": [
            {"name": "PG_HOST", "value": "${db_host}"},
            {"name": "PG_DATABASE", "value": "${db_name}"},
            {"name": "PG_USER", "value": "${db_user}"},
            {"name": "PG_PASSWORD", "value": "${db_pass}"},
            {"name": "PG_PORT", "value": "${port}"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "api"
            }
        },
        "portMappings": [
            {
                "containerPort": 5000,
                "hostPort": 5000
            }
        ],
        "mountPoints": [
        ]
    },
    {
        "name": "proxy",
        "image": "${proxy_image}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": 8000,
                "hostPort": 8000
            }
        ],
        "memoryReservation": 256,
        "environment": [
            {"name": "APP_PORT", "value": "5000"},
            {"name": "CLIENT_PORT", "value": "3000"},
            {"name": "LISTEN_PORT", "value": "8000"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "proxy"
            }
        },
        "mountPoints": [

        ]
    },
    {
        "name": "client",
        "image": "${frontend_image}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ],
        "memoryReservation": 128,
        "environment": [
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "client"
            }
        },
        "mountPoints": [
        ]
    }
]
