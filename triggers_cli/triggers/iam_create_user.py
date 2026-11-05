import logging
import boto3

LOGGER = logging.getLogger()

def main():
    """Create new IAM User and delete the user."""
    LOGGER.info(f"Triggering user creation and deletion.")

    iam = boto3.client('iam')

    creation = iam.create_user(
        UserName='purplelab-sample-user',
        Tags=[
            {
                'Key': 'scenario',
                'Value': 'purplelab'
            }
        ],
    )

    LOGGER.info(f"""
        [+] User successfully created:
            Arn: {creation['User']['Arn']}
            UserId: {creation['User']['UserId']}
            UserName: {creation['User']['UserName']}
    """)

    iam.delete_user(
        UserName='purplelab-sample-user'
    )

    LOGGER.info(f"""
        [+] User successfully deleted:
            Arn: {creation['User']['Arn']}
            UserId: {creation['User']['UserId']}
            UserName: {creation['User']['UserName']}
    """)

if __name__ == "__main__":
    main()