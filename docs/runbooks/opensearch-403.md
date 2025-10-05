# Runbook: OpenSearch 403

- Confirm the request is signed with SigV4.
- Verify ECS task IAM role includes OpenSearch permissions.
- Ensure network path (VPC endpoints / security groups) allows egress.
