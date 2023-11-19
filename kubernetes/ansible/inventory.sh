#!/bin/bash

master_ip=$(cd ../terraform && terraform output master_ip)
worker_ip=$(cd ../terraform && terraform output worker_ip)

cat <<EOF
{
  "master": {
    "hosts": [$master_ip]
  },
  "worker": {
    "hosts": [$worker_ip]
  }
}
EOF

