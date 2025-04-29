import boto3
import os

rds_client = boto3.client('rds')
asg_client = boto3.client('autoscaling')

def handler(event, context):
    # Environment variables
    replica_identifier = os.environ['REPLICA_IDENTIFIER']
    asg_name = os.environ['ASG_NAME']
    desired_capacity = int(os.environ['ASG_DESIRED_CAPACITY'])
    min_size = int(os.environ['ASG_MIN_SIZE'])
    max_size = int(os.environ['ASG_MAX_SIZE'])

    try:
        # Promote the RDS Read Replica
        print(f"Promoting RDS read replica: {replica_identifier}")
        rds_client.promote_read_replica(
            DBInstanceIdentifier=replica_identifier
        )
        print("Replica promotion initiated successfully.")

        # Update the ASG settings
        print(f"Updating ASG: {asg_name}")
        asg_client.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=desired_capacity,
            MinSize=min_size,
            MaxSize=max_size
        )
        print(f"ASG '{asg_name}' updated successfully.")

        return {
            'statusCode': 200,
            'body': 'RDS replica promotion and ASG update initiated successfully.'
        }

    except Exception as e:
        print(f"Error occurred: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
